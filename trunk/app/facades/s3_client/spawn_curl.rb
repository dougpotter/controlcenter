class S3Client::SpawnCurl
  def initialize(options={})
    @command = options[:command] || %w(/usr/bin/env curl)
    @s3_host = AwsConfiguration.s3_host || 's3.amazonaws.com'
    @s3_port = AwsConfiguration.s3_port || 443
    @s3_protocol = AwsConfiguration.s3_protocol || 'https'
    @timeout = options[:timeout]
    @debug = options[:debug]
  end
  
  def put_file(bucket, remote_path, local_path)
    if @debug
      debug_print "S3put #{local_path} -> #{bucket}:#{remote_path}"
    end
    
    url = build_url(bucket, remote_path)
    cmd = build_command('-T', local_path, url)
    
    if @debug
      debug_print "Curl #{cmd.join(' ')}"
    end
    
    Subprocess.spawn_check(cmd)
  end
  
  def list_bucket_files(bucket)
    if @debug
      debug_print "S3list #{bucket}"
    end
    
    # todo fill this
  end
  
  private
  
  def build_command(*args)
    if @command.is_a?(Array)
      cmd = @command.dup
    else
      cmd = [@command]
    end
    if @http_username
      cmd << '-u'
      # note that curl claims it will prompt for password if
      # --user is given and password is not given
      cmd << "#{@http_username}:#{@http_password}"
    end
    if @timeout
      # curl's -y/--speed-time is in fact exactly equivalent
      # to timeout, provided -Y/--speed-limit is set to default 1
      cmd << '--connect-timeout'
      cmd << @timeout.to_s
      cmd << '-y'
      cmd << @timeout.to_s
    end
    unless @debug
      cmd << '-s'
    end
    cmd << '-f'
    cmd + args
  end
  
  def build_url(bucket, remote_path)
    "#{@s3_protocol}://#{@s3_host}:#{@s3_port}/#{bucket}/#{remote_path}"
  end
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
