require_dependency 'subprocess'

class HttpClient::SpawnWget < HttpClient::Base
  include SpawnMixin
  
  # allowed options:
  # :command
  #   Examples:
  #   :command => 'wget'
  #   :command => '/usr/bin/wget'
  #   :command => ['/usr/bin/env', 'wget']
  # :http_username
  # :http_password
  # :timeout
  # :debug
  def initialize(options={})
    @command = options[:command] || %w(/usr/bin/env wget)
    @http_username, @http_password = options[:http_username], options[:http_password]
    @timeout = options[:timeout]
    @debug = options[:debug]
  end
  
  def fetch(url)
    if @debug
      debug_print "Fetch #{url}"
    end
    
    cmd = build_command('-O', '-', url)
    if @debug
      debug_print "Wget: #{cmd}"
    end
    Subprocess.get_output(cmd)
  end
  
  def download(url, local_path)
    if @debug
      debug_print "Download #{url} -> #{local_path}"
    end
    
    cmd = build_command('-O', local_path, url)
    if @debug
      debug_print "Wget: #{cmd}"
    end
    Subprocess.spawn_check(cmd)
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
      cmd << '--user'
      cmd << @http_username
    end
    if @http_password
      cmd << '--password'
      cmd << @http_password
    end
    if @timeout
      cmd << '--timeout'
      cmd << @timeout.to_s
    end
    unless @debug
      cmd << '-q'
    end
    cmd << '--no-check-certificate'
    cmd + args
  end
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
