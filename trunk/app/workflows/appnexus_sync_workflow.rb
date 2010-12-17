class AppnexusSyncWorkflow
  include Workflow::ConfigurationRetrieval
  
  def self.data_provider_name
    'Appnexus'
  end
  
  attr_reader :params
  
  def initialize(parameters)
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
    bucket, path = params[:s3_xguid_list_prefix].split(':', 2)
    input_url = "s3n://#{bucket}/#{path}/"
    bucket, path = params[:output_prefix].split(':', 2)
    timestamp = Time.now
    hour = timestamp.hour
    hour_range = "#{'%02d' % hour}00-#{'%02d' % ((hour + 1) % 24)}00"
    appnexus_list_path = "#{path}/seg-data/all/#{params[:partner_code]}/aid-#{params[:audience_code]}/#{timestamp.strftime('%Y%m%d')}/#{hour_range}/"
    appnexus_list_location = "#{bucket}:#{appnexus_list_path}"
    output_url = "s3n://#{bucket}/#{appnexus_list_path}"
    bucket, path = params[:lookup_prefix].split(':', 2)
    entries = find_subdirs(bucket, path)
    unless most_recent_lookup_subdir = entries[-1]
      raise "Were not able to find lookup directory"
    end
    lookup_url = "s3n://#{bucket}/#{path}/#{most_recent_lookup_subdir}/"
    
    cmd = params[:emr_command].dup
    cmd += [
      '--create',
      '--name', 'appnexus-list-generate',
      '--log-uri', params[:log_url],
      '--num-instances', params[:instance_count],
      '--instance-type', params[:instance_type],
      '--jar', params[:code_url],
      '--main-class', 'net.xgraph.mapreduce.appnexus.ApnListGenerate',
      '--arg', '/mnt/reduce1-output/',
      '--arg', input_url,
      '--arg', lookup_url,
      '--arg', params[:appnexus_segment_id],
      '--arg', params[:audience_code],
      '--arg', params[:ttl],
      '--arg', params[:appnexus_member_id],
      '--arg', output_url,
      '--step-name', "ApnListGenerate #{params[:audience_code]}/#{params[:appnexus_segment_id]} #{Time.now}",
    ]
    output = run(cmd)
    if output =~ /^Created job flow (j-\w+)$/
      job_id = $1
    else
      raise "Output did not contain job id: #{output}"
    end
    {:appnexus_list_location => appnexus_list_location, :emr_jobflow_id => job_id}
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
    when 'completed'
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
    # should have a single file
    unless files.length == 1
      raise "Multiple files found: #{files.join(', ')}"
    end
    get_file(bucket, files[0]) do |f|
      unique = Digest::MD5.new.hexdigest(1.upto(5).to_a.map { rand.to_s[2..-1] }.join)
      filename = "seg-#{params[:appnexus_member_id]}-#{unique}"
      remote_path = params[:sftp_path]
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
  
  def run(cmd)
    cmd = cmd.map do |part|
      if part.nil?
        raise "Command line has nil arguments - probably something is not specified correctly: #{cmd.inspect}"
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
end
