require 'fileutils'
require_dependency 'semaphore'

class ClearspringExtractWorkflow < Workflow::Base
  class << self
    def default_config_path
      YamlConfiguration.absolutize('workflows/clearspring')
    end
    
    def configuration(options={})
      default_options = {:config_path => default_config_path}
      Workflow::Configuration.new(default_options.update(options))
    end
  end
  
  attr_reader :params
  private :params
  
  def channel
    params[:channel]
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
      
      if params[:record]
        absolute_file_urls.each do |url|
          note_data_provider_file_discovered(url)
        end
      end
      
      absolute_file_urls.reject! { |url| !should_download_url?(url) }
      absolute_file_urls
    end
  end
  
  def perform_extraction(file_url)
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
    if params[:once]
      create_data_provider_file(file_url) do |file|
        file.status = DataProviderFile::EXTRACTED
        file.extracted_at = Time.now
      end
    end
    
    unless params[:keep_downloaded]
      if params[:debug]
        debug_print("Remove #{local_path}")
      end
      FileUtils.rm(local_path)
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
      retry_network_errors(@network_error_retry_options) do
        retry_aws_errors(@network_error_retry_options) do
          @s3_client.put_file(s3_bucket, build_s3_path(local_path), local_path)
        end
      end
    end
  end
  
  # -----
  
  def validate_file_url_for_extraction!(url)
    unless should_download_url?(url)
      raise Workflow::FileSpecMismatch, "Url does not match download parameters: #{url}"
    end
  end
  
  # -----
  
  def build_data_source_url
    "#{params[:data_source_root]}/#{channel.name}"
  end
  
  def build_absolute_url(remote_url, file)
    File.join(remote_url, file)
  end
  
  def prefix_to_download
    basename_prefix(
      :channel_name => channel.name,
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
    absolute_to_relative_path(params[:data_source_root], remote_url)
  end
  
  def build_local_path(remote_relative_path)
    File.join(params[:download_root_dir], remote_relative_path)
  end
  
  def s3_bucket
    params[:s3_bucket]
  end
  
  def build_s3_prefix
    # date is required, it should always be given to workflow
    "#{params[:clearspring_pid]}/v2/raw-#{channel.name}/#{params[:date]}"
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
    file = channel.data_provider_files.find(:first,
      :conditions => [
        'data_provider_files.url=? and status not in (?)',
        file_url,
        [DataProviderFile::DISCOVERED, DataProviderFile::BOGUS]
      ]
    )
    return !file.nil?
  end
  
  # readiness heuristic - to be written
  def fully_uploaded?(file_url)
    true
  end
end
