require_dependency 'subprocess'

class HttpClient::SpawnCurl < HttpClient::Base
  include SpawnMixin
  
  # Exit statuses: http://curl.haxx.se/docs/manpage.html#EXIT or
  # http://man.cx/curl%281%29#sec8
  ERROR_TIMEOUT = 28
  
  # allowed options:
  # :command
  #   Examples:
  #   :command => 'curl'
  #   :command => '/usr/bin/curl'
  #   :command => ['/usr/bin/env', 'curl']
  # :http_username
  # :http_password
  # :timeout
  # :debug
  # :logger
  def initialize(options={})
    super(options)
    @command = options[:command] || %w(/usr/bin/env curl)
    @http_username, @http_password = options[:http_username], options[:http_password]
    @timeout = options[:timeout]
    @debug = options[:debug]
  end
  
  def fetch(url)
    if @debug
      debug_print "Fetch #{url}"
    end
    
    cmd = build_command('-o', '-', url)
    if @debug
      debug_print "Curl: #{cmd.join(' ')}"
    end
    get_output(url, cmd)
  end
  
  def download(url, local_path)
    if @debug
      debug_print "Download #{url} -> #{local_path}"
    end
    
    cmd = build_command('-o', local_path, url)
    if @debug
      debug_print "Curl: #{cmd.join(' ')}"
    end
    spawn_check(url, cmd)
  end
  
  def get_url_content_length(url)
    if @debug
      debug_print "Head #{url}"
    end
    
    cmd = build_command('-I', url)
    if @debug
      debug_print "Curl: #{cmd.join(' ')}"
    end
    output = get_output(url, cmd)
    if /^content-length:\s+(\d+)/ =~ output.downcase
      content_length = $1.to_i
    else
      raise HttpClient::UnsupportedServer, "Content length not found in returned headers"
    end
    content_length
  end
  
  private
  
  def build_command(*args)
    cmd = common_command_options
    if @http_username
      cmd << '-u'
      # note that curl claims it will prompt for password if
      # --user is given and password is not given
      cmd << "#{@http_username}:#{@http_password}"
    end
    cmd + args
  end
  
  def common_command_options
    if @command.is_a?(Array)
      cmd = @command.dup
    else
      cmd = [@command]
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
    cmd
  end
  
  def exception_map
    mapper = lambda do |exc, url|
      case exc.exitstatus
      when ERROR_TIMEOUT
        convert_and_raise(exc, HttpClient::NetworkTimeout, url)
      end
      # returning will cause original exception to be reraised
    end
    
    [
      [Subprocess::CommandFailed, mapper],
    ]
  end
end
