require 'fileutils'
require_dependency 'semaphore'

class ClearspringExtractWorkflow < Workflow::ExtractBase
  include ClearspringAccess
  
  class << self
    def default_config_path
      YamlConfiguration.absolutize('workflows/clearspring')
    end
    
    def configuration(options={})
      default_options = {:config_path => default_config_path}
      Workflow::Configuration.new(default_options.update(options))
    end
  end
  
  def initialize(params)
    super(params)
    initialize_params(params)
    @http_client = create_http_client(@params)
    @parser = WebParser.new
    @gzip_transformer = GzipSplitter.new(:debug => @params[:debug], :logger => @logger)
    @s3_client = create_s3_client(@params)
  end
  
  private
  
  def perform_extraction(file_url)
    validate_source_url_for_extraction!(file_url)
    local_path = download(file_url)
    split_paths = split(local_path)
    split_paths.each do |path|
      upload(path, s3_bucket, build_s3_path(path))
    end
    
    unless params[:keep_temporary]
      split_paths.each do |path|
        if params[:debug]
          debug_print("Remove #{path}")
        end
        FileUtils.rm(path)
      end
    end
    
    possibly_record_source_url_extracted(file_url)
    
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
    
    local_path = File.join(params[:temp_root_dir], filename_format)
    FileUtils.mkdir_p(File.dirname(local_path))
    
    @gzip_transformer.transform(
      input_path,
      params[:temp_root_dir],
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
  
  # -----
  
  # Readiness heuristic - for now we consider a file to be fully uploaded
  # if it was modified over 2 hours ago.
  def fully_uploaded?(file_url)
    @http_client.get_url_time(file_url) < Time.now - 2.hours
  end
end
