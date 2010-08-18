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
    get_output(cmd)
  end
  
  def download(url, local_path)
    if @debug
      debug_print "Download #{url} -> #{local_path}"
    end
    
    cmd = build_command('-o', local_path, url)
    if @debug
      debug_print "Curl: #{cmd.join(' ')}"
    end
    spawn_check(cmd)
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
      # curl has no read timeout option, apparently
      cmd << '--connect-timeout'
      cmd << @timeout.to_s
    end
    unless @debug
      cmd << '-s'
    end
    cmd << '-f'
    cmd + args
  end
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
