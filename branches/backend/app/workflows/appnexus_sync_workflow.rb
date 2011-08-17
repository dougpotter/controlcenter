class AppnexusSyncWorkflow
  class InvalidLookupPrefix < StandardError
  end
  
  include Workflow::Logger
  include Workflow::DebugPrint
  include Workflow::ConfigurationRetrieval
  
  def self.data_provider_name
    'Appnexus'
  end
  
  attr_reader :params
  
  def initialize(parameters)
    initialize_logger
    config = self.class.configuration
    config = config.to_hash.dup
    config.keys.each do |key|
      key = key.to_s
      if key.starts_with?('list_create_')
        config[key[12..-1]] = config.delete(key)
      end
    end
    @params = config.update(parameters)
  end
  
  # Launches a map-reduce job to create appnexus list to upload.
  # The list is made up of appnexus user ids and appnexus segment id pairs.
  # It is obtained by joining xguids to xguid-appnexus user id map.
  # Currently the work is done by elastic map reduce.
  def launch_create_list
    emr_params = build_emr_parameters(params)
    
    cmd = params[:emr_command] + [
      '--create',
      '--name', emr_params[:name],
      '--log-uri', emr_params[:log_url],
      '--num-instances', emr_params[:instance_count],
      '--instance-type', emr_params[:instance_type],
      '--jar', emr_params[:code_url],
      '--main-class', emr_params[:main_class],
      '--arg', emr_params[:temp_dir],
      '--arg', emr_params[:input_url],
      '--arg', emr_params[:lookup_url],
      '--arg', emr_params[:appnexus_segment_id],
      '--arg', emr_params[:audience_code],
      '--arg', emr_params[:ttl],
      '--arg', emr_params[:appnexus_member_id],
      '--arg', emr_params[:output_url],
      '--step-name', emr_params[:step_name],
    ]
    output = run(cmd)
    if output =~ /^Created job flow (j-\w+)$/
      job_id = $1
    else
      raise "Output did not contain job id: #{output}"
    end
    
    # derive output location from s3 url
    appnexus_list_location = s3_url_to_location(emr_params[:output_url])
    lookup_location = s3_url_to_location(emr_params[:lookup_url])
    
    {
      :appnexus_list_location => appnexus_list_location,
      :lookup_location => lookup_location,
      :emr_jobflow_id => job_id,
    }
  end
  
  # Checks whether the map-reduce job to create appnexus list has finished.
  def check_create_list(job_id)
    cmd = params[:emr_command].dup
    cmd += [
      '--describe',
      '--jobflow', job_id
    ]
    output = run(cmd)
    # output is json but we can read it with yaml to avoid additional
    # dependencies
    info = YAML.load(output)
    begin
      job_state = info['JobFlows'][0]['ExecutionStatusDetail']['State'].downcase
    rescue NoMethodError
      raise "Job state not found in job info: #{info}"
    end
    result = {:state => job_state}
    result[:success] = case job_state
    when 'completed', 'shutting_down'
      true
    when 'failed', 'terminated'
      false
    else
      # XXX raise exception?
      nil
    end
    result
  end
  
  # Uploads the generated appnexus list to appnexus.
  def upload_list(appnexus_list_location)
    require 'net/sftp'
    require 'digest/md5'
    bucket, prefix = appnexus_list_location.split(':', 2)
    files = find_files(bucket, prefix)
    if files.empty?
      raise "AppNexus list generation produced no output files"
    end
    # should have a single file
    unless files.length == 1
      raise "Multiple files found: #{files.join(', ')}"
    end
    get_file(bucket, files[0]) do |f|
      filename = determine_appnexus_filename(params)
      remote_path = params[:sftp_path]
      unless remote_path
        raise Workflow::ConfigurationError, "sftp_path not specified for appnexus workflow"
      end
      remote_path += '/' if remote_path && remote_path[-1] != ?/
      remote_path += filename
      options = {}
      if private_key_path = params[:sftp_private_key_path]
        options[:keys] = [private_key_path]
      end
      Net::SFTP.start(params[:sftp_host], params[:sftp_username], options) do |sftp|
        sftp.file.open(remote_path, 'w') do |remote_f|
          while chunk = f.read(65536)
            remote_f.write(chunk)
          end
        end
      end
    end
  end
  
  private
  
  # Builds parameters for EMR job generating appnexus list given a merge of
  # user-supplied parameters (via XGCC ui) and defaults specified in XGCC
  # configuration files.
  def build_emr_parameters(params)
    bucket, path = params[:s3_xguid_list_prefix].split(':', 2)
    input_url = "s3n://#{bucket}/#{path}"
    bucket, path = params[:output_prefix].split(':', 2)
    timestamp = Time.now
    hour = timestamp.hour
    hour_range = "#{'%02d' % hour}00-#{'%02d' % ((hour + 1) % 24)}00"
    appnexus_list_path = "#{path}/seg-data/all/#{params[:partner_code]}/aid-#{params[:audience_code]}/#{timestamp.strftime('%Y%m%d')}/#{hour_range}/"
    output_url = "s3n://#{bucket}/#{appnexus_list_path}"
    lookup_url = determine_lookup_url(params)
    
    # keep the keys arranged in the same order as arguments to emr command
    {
      :name => 'appnexus-list-generate',
      :log_url => params[:log_url],
      :instance_count => params[:instance_count],
      :instance_type => params[:instance_type],
      :code_url => params[:code_url],
      :main_class => 'net.xgraph.mapreduce.appnexus.ApnListGenerate',
      :temp_dir => '/mnt/reduce1-output/',
      :input_url => input_url,
      :output_url => output_url,
      :appnexus_segment_id => params[:appnexus_segment_id],
      :audience_code => params[:audience_code],
      :ttl => params[:ttl],
      :appnexus_member_id => params[:appnexus_member_id],
      :lookup_url => lookup_url,
      :step_name => "ApnListGenerate #{params[:audience_code]}/#{params[:appnexus_segment_id]} #{timestamp}",
    }
  end
  
  def s3_url_to_location(url)
    url.sub(%r|^s3n://([^/]+)/|, '\1:')
  end
  
  def run(cmd)
    cmd = cmd.map do |part|
      if part.nil?
        raise ArgumentError, "Command line has nil arguments - probably something is not specified correctly: #{cmd.inspect}"
      end
      # this converts integers to strings
      part.to_s
    end
    env = {
      'ELASTIC_MAPREDUCE_ACCESS_ID' => AwsConfiguration.access_key_id,
      'ELASTIC_MAPREDUCE_PRIVATE_KEY' => AwsConfiguration.secret_access_key,
    }
    Rails.logger.info("Launching: #{cmd.inspect}")
    Subprocess.get_output(cmd, :env => env)
  end
  
  def lock(job_id)
    options = {
      :name => job_id.to_s,
      :location => AppnexusSyncJob.name,
      :capacity => 1,
      :timeout => 30.minutes,
      :wait => false,
      :create_resource => true,
    }
    
    if params[:debug]
      debug_print("Obtaining lock to check job #{job_id}")
    end
    
    Semaphore::Arbitrator.instance.lock(options) do
      yield
    end
  rescue Semaphore::ResourceBusy
    if params[:debug]
      debug_print("Job #{job_id} busy")
    end
    
    # will retry later
  end
  
  # XXX are we exposing too much by making lock public?
  public :lock
  
  def find_files(bucket, prefix)
    s3_client.list_bucket_files(bucket, prefix)
  end
  
  def find_subdirs(bucket, path)
    s3_client.list_bucket_subdirs(bucket, path)
  end
  
  def get_file(bucket, remote_path)
    require 'tempfile'
    Tempfile.open('appnexus_sync') do |f|
      s3_client.get_io(bucket, remote_path, f)
      f.rewind
      yield f
    end
  end
  
  def s3_client
    @s3_client ||= S3Client::RightAws.new
  end
  
  def choose_most_recent_ending_subdir(basenames)
    endpoints = []
    basenames.each_with_index do |basename, index|
      if basename =~ /^(\d{8})-(\d{8})$/
        endpoints << [$2, index]
      end
    end
    latest_endpoint = latest_index = nil
    endpoints.each do |(endpoint, index)|
      if latest_endpoint.nil? || endpoint > latest_endpoint
        latest_endpoint = endpoint
        latest_index = index
      end
    end
    if latest_endpoint.nil?
      raise InvalidLookupPrefix, "None of the subdirs looked like lookup table subdirs"
    end
    basenames[latest_index]
  end
  
  def determine_lookup_url(params)
    bucket, path = params[:lookup_prefix].split(':', 2)
    lookup_start_date = params[:lookup_start_date]
    lookup_end_date = params[:lookup_end_date]
    if lookup_start_date && lookup_end_date
      subdir = "#{lookup_start_date}-#{lookup_end_date}"
    elsif lookup_start_date || lookup_end_date
      # only one endpoint specified - we do not currently allow this
      raise ArgumentError, "Only one endpoint specified for lookup date range"
    else
      entries = find_subdirs(bucket, path)
      unless subdir = choose_most_recent_ending_subdir(entries)
        raise "Were not able to find lookup directory"
      end
    end
    lookup_url = "s3n://#{bucket}/#{path}/#{subdir}/"
  end
  
  def determine_appnexus_filename(params)
    unique = Digest::MD5.new.hexdigest(1.upto(5).to_a.map { rand.to_s[2..-1] }.join)
    unique = unique[0...10]
    "seg-#{params[:appnexus_member_id]}-#{unique}"
  end
end
