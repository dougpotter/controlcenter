require 'fileutils'
require_dependency 'semaphore'

class ClearspringExtractWorkflow < Workflow::Base
  class WorkflowError < StandardError; end
  class DataProviderNotFound < WorkflowError; end
  class DataProviderChannelNotFound < WorkflowError; end
  
  class << self
    def default_config_path
      YamlConfiguration.absolutize('workflows/clearspring')
    end
  end
  
  class Configuration
    # Returns parameters from configuration file.
    #
    # Allowed options:
    #
    # :config_path
    def initialize(options={})
      config_path = options[:config_path] || ClearspringExtractWorkflow.default_config_path
      config = YamlConfiguration.load(config_path)
      @config_params = {
        :data_source_path => config.clearspring_root_url,
        :download_root_dir => config.download_root_dir,
        :gzip_root_dir => config.temp_root_dir,
        :http_username => config.clearspring_http_username,
        :http_password => config.clearspring_http_password,
        :net_io_timeout => config.clearspring_net_io_timeout,
        :s3_bucket => config.s3_bucket,
        :clearspring_pid => config.clearspring_pid,
        # options
        :http_client => config.http_client,
        :system_timer => config.force_system_timer,
        :lock => config.lock,
        :once => config.once,
        :debug => config.debug,
        :debug_output_path => config.debug_output_path,
        :keep_downloaded => config.keep_downloaded,
        :keep_temporary => config.keep_temporary,
        :verify => config.verify,
      }
      postprocess_params
    end
    
    def dup
      new = super
      new.instance_variable_set('@config_params', @config_params.dup)
      new
    end
    
    def update(options)
      options.each do |key, value|
        unless value.nil?
          @config_params[key] = value
        end
      end
      postprocess_params
      self
    end
    
    def merge(options)
      dup.update(options)
    end
    
    def to_hash
      # typically users expect to_* methods to return copies of data
      @config_params.dup
    end
    
    private
    
    # XXX consider refactoring this
    def postprocess_params
      if path = @config_params[:debug_output_path]
        # will also modify the hash
        path.gsub!(/:timestamp\b/, Time.now.strftime('%Y%m%d-%H%M%S'))
      end
      if @config_params[:once]
        @config_params[:lock] = true
      end
    end
  end
  
  attr_reader :params
  private :params
  
  def channel
    params[:data_source]
  end
  
  def date
    params[:date]
  end
  
  def hour
    params[:hour]
  end
  
  def initialize(params)
    super(params)
    initialize_params(params)
    @http_client = create_http_client(@params)
    @parser = WebParser.new
    @gzip_transformer = GzipSplitter.new(:debug => @params[:debug], :logger => @logger)
    @s3_client = create_s3_client(@params)
  end
  
  def run
    files = list_data_source_files
    # if :once option was given, #extract will raise a workflow error
    # for files that are being extracted elsewhere or that have been already extracted.
    # #run is called to do both discovery and extraction, and should extract all
    # extractable files. therefore we catch and ignore extraction in progress
    # and file already extracted workflow errors
    files.each do |file|
      begin
        extract(file)
      rescue Workflow::FileExtractionInProgress, Workflow::FileAlreadyExtracted
        # igrore
      end
    end
  end
  
  def discover
    list_data_source_files
  end
  
  def extract(file_url)
    if params[:lock]
      extract_with_locking(file_url)
    else
      extract_without_locking(file_url)
    end
  end
  
  def should_download_url?(url)
    File.basename(url).starts_with?(prefix_to_download)
  end
  
  private
  
  def initialize_params(params)
    @params = params
    @network_error_retry_options = {:retry_count => 10, :sleep_time => 10}
    @update_process_status = params[:update_process_status]
  end
  
  def list_data_source_files
    with_process_status(:action => 'listing files') do
      url = build_data_source_url
      page_text = retry_network_errors(@network_error_retry_options) do
        @http_client.fetch(url + '/')
      end
      files = @parser.parse_any_httpd_file_list(page_text)
      absolute_file_urls = files.map { |file| build_absolute_url(url, file) }
      absolute_file_urls.reject! { |url| !should_download_url?(url) }
      absolute_file_urls
    end
  end
  
  def extract_without_locking(file_url, options={})
    validate_file_url_for_extraction!(file_url)
    local_path = download(file_url)
    split_paths = split(local_path)
    split_paths.each do |path|
      upload(path)
    end
    
    unless params[:keep_temporary]
      split_paths.each do |path|
        if params[:debug]
          debug_print("Remove #{path}")
        end
        FileUtils.rm(path)
      end
    end
    
    # See the comment in create_data_provider_file regarding mixing locked
    # and non-locked runs. Status files are only created for once runs
    # (which are also locked).
    if options[:once]
      create_data_provider_file(file_url)
    end
    
    unless params[:keep_downloaded]
      if params[:debug]
        debug_print("Remove #{local_path}")
      end
      FileUtils.rm(local_path)
    end
  end
  
  def extract_with_locking(file_url)
    lock(file_url) do
      extract_without_locking(file_url, :once => params[:once])
    end
  end
  
  def download(url)
    with_process_status(:action => "downloading #{File.basename(url)}") do
      remote_relative_path = url_to_relative_data_source_path(url)
      local_path = build_local_path(remote_relative_path)
      FileUtils.mkdir_p(File.dirname(local_path))
      retry_network_errors(@network_error_retry_options) do
        @http_client.download(url, local_path)
      end
      local_path
    end
  end
  
  def split(input_path)
    dest_files = with_process_status(:action => "splitting #{File.basename(input_path)}") do
      perform_split(input_path)
    end
    
    if params[:verify]
      with_process_status(:action => "verifying split #{File.basename(input_path)}") do
        verify_split(input_path, dest_files)
      end
    end
    
    dest_files
  end
  
  def perform_split(input_path)
    local_relative_path = absolute_to_relative_path(params[:download_root_dir], input_path)
    local_relative_path =~ /^(.*?)(\.log\.gz)?$/
    name, ext = $1, $2
    filename_format = "#{name.sub('%', '%%')}.%03d#{ext}"
    
    local_path = File.join(params[:gzip_root_dir], filename_format)
    FileUtils.mkdir_p(File.dirname(local_path))
    
    @gzip_transformer.transform(
      input_path,
      params[:gzip_root_dir],
      filename_format
    )
  end
  
  def verify_split(input_path, output_paths)
    source_md5 = compute_md5(input_path)
    dest_md5 = compute_md5(*output_paths)
    if source_md5 != dest_md5
      raise SplitVerificationFailed, "Split files differ from original #{output_paths.inspect} vs #{input_path.inspect}"
    end
  end
  
  def compute_md5(*paths)
    require 'digest/md5'
    md5 = Digest::MD5.new
    if params[:debug]
      debug_print "Gunzip #{paths.join(' ')}"
    end
    paths.each do |path|
      IO.popen("gzip -cd #{path}") do |file|
        while chunk = file.read(Subprocess::BUFSIZE)
          md5.update(chunk)
        end
      end
    end
    md5.hexdigest
  end
  
  def upload(local_path)
    with_process_status(:action => "uploading #{File.basename(local_path)}") do
      retry_aws_errors(@network_error_retry_options) do
        @s3_client.put_file(s3_bucket, build_s3_path(local_path), local_path)
      end
    end
  end
  
  # -----
  
  def validate_file_url_for_extraction!(url)
    unless should_download_url?(url)
      raise Workflow::FileSpecMismatch, "Url does not match download parameters: #{url}"
    end
  end
  
  def lock(remote_url)
    options = {
      :name => remote_url,
      :location => 'clearspring',
      :capacity => 1,
      :timeout => 30.minutes,
      :wait => false,
      :create_resource => true,
    }
    
    if params[:debug]
      debug_callback = lambda do |message|
        debug_print "#{message} for #{remote_url}"
      end
      
      options[:debug_callback] = debug_callback
    end
    
    # ok_to_extract? needs to be in a critical section for each file,
    # otherwise two processes may check e.g. local caches simultaneously
    # and both decide to process the same file.
    #
    # yield is is the critical section because local caches are created
    # by extraction process. if we used special marker files then
    # extraction could be brought outside of the critical section.
    Semaphore::Arbitrator.instance.lock(options) do
      unless fully_uploaded?(remote_url)
        raise Workflow::FileNotReady, "File is not ready to be extracted: #{remote_url}"
      end
      if ok_to_extract?(remote_url)
        yield
      else
        if params[:debug]
          debug_print "File is already extracted: #{remote_url}"
        end
        raise Workflow::FileAlreadyExtracted, "File is already extracted: #{remote_url}"
      end
    end
  rescue Semaphore::ResourceBusy
    # someone else is processing the file, do nothing
    if params[:debug]
      debug_print "Lock is busy for #{remote_url}"
    end
    # raise the exception so that driver code can exit the process
    # with appropriate exit code
    raise Workflow::FileExtractionInProgress, "File is being extracted: #{remote_url}"
  end
  
  # Required options:
  # :retry_count
  # :sleep_time
  # :exception_class or :exception_classes
  # Optional options:
  # :extra_callback
  def retry_errors(options)
    if options[:exception_class] && options[:exception_classes]
      raise ArgumentError, "Cannot specify both :exception_class and :exception_classes"
    end
    exception_classes = options[:exception_classes] || [options[:exception_class]]
    extra_callback = options[:extra_callback]
    0.upto(options[:retry_count]) do |index|
      begin
        return yield
      rescue Exception => e
        unless exception_classes.detect { |klass| e.is_a?(klass) }
          raise
        end
        if params[:debug]
          debug_print "Retrying after exception: #{e} (#{e.class}) at #{e.backtrace.first}"
        end
        
        if index == options[:retry_count]
          raise
        else
          if extra_callback
            extra_callback.call(e)
          end
          sleep(options[:sleep_time])
        end
      end
    end
  end
  
  def retry_network_errors(options)
    default_options = {:exception_class => HttpClient::NetworkError}
    retry_errors(default_options.update(options)) do
      yield
    end
  end
  
  def retry_aws_errors(options)
    callback = lambda do |exception|
      http_code = exception.http_code.to_i
      if http_code < 500 || http_code >= 600
        # only retry 5xx errors
        raise
      end
    end
    default_options = {:exception_class => S3Client::HttpError, :extra_callback => callback}
    retry_errors(default_options.update(options)) do
      yield
    end
  end
  
  # -----
  
  def build_data_source_url
    "#{params[:data_source_path]}/#{params[:data_source]}"
  end
  
  def build_absolute_url(remote_url, file)
    File.join(remote_url, file)
  end
  
  def prefix_to_download
    basename_prefix(
      :channel_name => params[:data_source],
      :date => params[:date], :hour => params[:hour]
    )
  end
  
  def basename_prefix(options)
    "#{options[:channel_name]}.#{date_with_hour(options)}"
  end
  
  def date_with_hour(options)
    str = options[:date].to_s
    if options[:hour]
      str += sprintf('-%02d00', options[:hour])
    end
    str
  end
  
  def url_to_relative_data_source_path(remote_url)
    absolute_to_relative_path(params[:data_source_path], remote_url)
  end
  
  def build_local_path(remote_relative_path)
    File.join(params[:download_root_dir], remote_relative_path)
  end
  
  def s3_bucket
    params[:s3_bucket]
  end
  
  def build_s3_prefix
    # date is required, it should always be given to workflow
    "#{params[:clearspring_pid]}/v2/raw-#{params[:data_source]}/#{params[:date]}"
  end
  
  def build_s3_path(local_path)
    filename = File.basename(local_path)
    "#{build_s3_prefix}/#{filename}"
  end
  
  # returns true if remote_url is not currently being extracted,
  # and had not been successfully extracted in the past.
  def ok_to_extract?(remote_url)
    if params[:once] and already_extracted?(remote_url)
      false
    else
      true
    end
  end
  
  def already_extracted?(file_url)
    channel = get_channel!(params[:data_source])
    file = channel.data_provider_files.find(:first,
      :conditions => [
        'data_provider_files.url=?',
        file_url
      ]
    )
    return !file.nil?
  end
  
  def create_data_provider_file(file_url)
    channel = get_channel!(params[:data_source])
    
    # Locked and lock-free runs should not be combined, since lock-free run may
    # overwrite data of the locked run and leave it in an inconsistent state and
    # the locked run would report success.
    #
    # Only create status files for once (which are locked) runs. This should serve
    # as a reminder to people to use locking if they want to see the status
    # (which in production should be just about always).
    file = DataProviderFile.create!(:url => file_url, :data_provider_channel => channel)

=begin alternative implementation
    file = channel.data_provider_files.find_by_url(file_url)
    if file
      # XXX already exists, check and update status?
    else
      begin
        file = DataProviderFile.create!(:url => file_url, :data_provider_channel => channel)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid
        # see if someone else created the file concurrently
        file = channel.data_provider_files.find_by_url(file_url)
        unless file
          raise
        end
      end
    end
=end
  end
  
  # Raises DataProviderNotFound if clearspring data provider does not exist
  def get_data_provider!
    unless @data_provider
      @data_provider = DataProvider.find_by_name('Clearspring', :include => :data_provider_channels)
      unless @data_provider
        raise DataProviderNotFound, "Clearspring data provider does not exist - is db seeded?"
      end
    end
    @data_provider
  end
  
  # Raises DataProviderChannelNotFound if the channel does not exist
  def get_channel!(channel_name)
    data_provider = get_data_provider!
    channel = data_provider.data_provider_channels.detect do |channel|
      channel.name == channel_name
    end
    unless channel
      raise DataProviderChannelNotFound, "Clearspring data provider channel not found: #{channel_name} - is db seeded?"
    end
    channel
  end
  
  # readiness heuristic - to be written
  def fully_uploaded?(file_url)
    true
  end
end
