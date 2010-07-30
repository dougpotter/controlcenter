require 'fileutils'

module Workflow
  # Base class for workflow errors
  class WorkflowError < StandardError; end
  
  # Another process had begun extracting the requested file.
  # Extraction may be actively proceeding, or the other process
  # may have died but its lock timeout had not yet passed.
  class FileExtractionInProgress < WorkflowError; end
  
  # The file had already been extracted with --once option.
  # This exception is only raised when --once option is given.
  # Without --once, it is possible to extract the same file
  # an arbitrary number of times.
  class FileAlreadyExtracted < WorkflowError; end
  
  # Raised when user requests a specific url to be downloaded
  # and provides date/hour/channel, and the url is actually not
  # in the specified date/hour/channel.
  class FileSpecMismatch < WorkflowError; end
  
  # Attempting to extract partially uploaded files.
  class FileNotReady < WorkflowError; end
end

class ClearspringExtractWorkflow
  attr_reader :params
  private :params
  
  def initialize(params)
    @params = params
    @http_client = HttpClient.new(:debug => @params[:debug])
    @parser = WebParser.new
    @gzip_transformer = GzipSplitter.new(:debug => @params[:debug])
    @s3_client = S3Client.new(:debug => @params[:debug])
  end
  
  def run
    files = list_files
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
    list_files
  end
  
  def extract(file_url)
    if params[:lock]
      extract_with_locking(file_url)
    else
      extract_without_locking(file_url)
    end
  end
  
  private
  
  def list_files
    url = build_data_source_url
    page_text = @http_client.fetch(url + '/')
    files = @parser.parse_any_httpd_file_list(page_text)
    absolute_file_urls = files.map { |file| build_absolute_url(url, file) }
    absolute_file_urls.reject! { |url| !should_download_url?(url) }
    absolute_file_urls
  end
  
  def extract_without_locking(file_url)
    validate_file_url_for_extraction!(file_url)
    local_path = download(file_url)
    split_paths = split(local_path)
    split_paths.each do |path|
      upload(path)
    end
    # See the comment in create_data_provider_file regarding mixing locked
    # and non-locked runs. Status files are only created for once runs
    # (which are also locked).
    if params[:once]
      create_data_provider_file(file_url)
    end
  end
  
  def extract_with_locking(file_url)
    lock(file_url) do
      extract_without_locking(file_url)
    end
  end
  
  def download(url)
    remote_relative_path = build_relative_path(url)
    local_path = build_local_path(remote_relative_path)
    FileUtils.mkdir_p(File.dirname(local_path))
    @http_client.download(url, local_path)
    local_path
  end
  
  def split(input_path)
    local_relative_path = figure_relative_path(params[:download_root_dir], input_path)
    local_relative_path =~ /^(.*?)(\.log\.gz)?$/
    name, ext = $1, $2
    filename_format = "#{name.sub('%', '%%')}.%03d#{ext}"
    
    local_path = File.join(params[:gzip_root_dir], filename_format)
    FileUtils.mkdir_p(File.dirname(local_path))
    
    dest_files = @gzip_transformer.transform(
      input_path,
      params[:gzip_root_dir],
      filename_format
    )
  end
  
  def upload(local_path)
    @s3_client.put_file(s3_bucket, build_s3_path(local_path), local_path)
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
  
  # -----
  
  def build_data_source_url
    "#{params[:data_source_path]}/#{params[:data_source]}"
  end
  
  def build_absolute_url(remote_url, file)
    File.join(remote_url, file)
  end
  
  def prefix_to_download
    prefix = "#{params[:data_source]}.#{params[:date]}"
    if params[:hour]
      prefix += sprintf('-%02d00', params[:hour])
    end
    prefix
  end
  
  def should_download_url?(url)
    File.basename(url).starts_with?(prefix_to_download)
  end
  
  def build_relative_path(remote_url)
    figure_relative_path(params[:data_source_path], remote_url)
  end
  
  def build_local_path(remote_relative_path)
    File.join(params[:download_root_dir], remote_relative_path)
  end
  
  def s3_bucket
    params[:s3_bucket]
  end
  
  def build_s3_path(local_path)
    filename = File.basename(local_path)
    path = "#{params[:clearspring_pid]}/v2/raw-#{params[:data_source]}/#{params[:date]}/#{filename}"
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
    file = DataProviderFile.find(:first, :include => {:data_provider_channel => :data_provider},
      :conditions => [
        'data_providers.name=? and data_provider_channels.name=? and data_provider_files.url=?',
        'Clearspring', params[:data_source], file_url
      ]
    )
    return !file.nil?
  end
  
  def create_data_provider_file(file_url)
    channel = DataProviderChannel.find(:first, :include => :data_provider,
      :conditions => ['data_providers.name=? and data_provider_channels.name=?',
        'Clearspring', params[:data_source]
      ]
    )
    unless channel
      raise ArgumentError, 'Channel not found'
    end
    
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
  
  # readiness heuristic - to be written
  def fully_uploaded?(file_url)
    true
  end
  
  # -----
  
  def figure_relative_path(root, absolute_path)
    root_len, abs_len = root.length, absolute_path.length
    if abs_len < root_len || absolute_path[0...root_len] != root
      raise ArgumentError, "Absolute path #{absolute_path} is not under #{root}"
    end
    relative_path = absolute_path[root_len...abs_len]
    if relative_path[0] == '/'
      relative_path = relative_path[1...relative_path.length]
    end
    relative_path
  end
  
  # ------
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
