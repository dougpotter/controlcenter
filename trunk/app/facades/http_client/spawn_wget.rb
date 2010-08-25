require_dependency 'subprocess'

# Note: wget is unsuitable for working with https connections because it does
# not properly implement timeout functionality when ssl is involved.
# See upstream bug: http://savannah.gnu.org/bugs/index.php?20523
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
      debug_print "Wget: #{cmd.join(' ')}"
    end
    get_output(url, cmd)
  end
  
  def download(url, local_path)
    if @debug
      debug_print "Download #{url} -> #{local_path}"
    end
    
    cmd = build_command('-O', local_path, url)
    if @debug
      debug_print "Wget: #{cmd.join(' ')}"
    end
    spawn_check(url, cmd)
  end
  
  private
  
  def build_command(*args)
    cmd = common_command_options
    if @http_username
      cmd << '--user'
      cmd << @http_username
    end
    if @http_password
      cmd << '--password'
      cmd << @http_password
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
      cmd << '--timeout'
      cmd << @timeout.to_s
    end
    unless @debug
      cmd << '-q'
    end
    cmd << '--no-check-certificate'
    cmd
  end
end
