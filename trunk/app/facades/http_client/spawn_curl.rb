require_dependency 'subprocess'

class HttpClient::SpawnCurl < HttpClient::Base
  include SpawnMixin
  
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
  def initialize(options={})
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
end
