require 'httpclient'

class HttpClient::Httpclient < HttpClient::Base
  # allowed options:
  # :http_username
  # :http_password
  # :timeout
  # :debug
  def initialize(options={})
    @timeout = options[:timeout]
    @debug = options[:debug]
    @client = HTTPClient.new
    if options[:http_username]
      @client.set_auth(nil, options[:http_username], options[:http_password])
    end
    if options[:timeout]
      @client.send_timeout = options[:timeout]
      @client.receive_timeout = options[:timeout]
    end
  end
  
  def fetch(url)
    if @debug
      debug_print "Fetch #{url}"
    end
    
    map_exceptions(url) do
      @client.get_content(url)
    end
  end
  
  def download(url, local_path)
    if @debug
      debug_print "Download #{url} -> #{local_path}"
    end
    
    File.open(local_path, 'w') do |file|
      map_exceptions(url) do
        @client.get(url) do |chunk|
          file << chunk
        end
      end
    end
  end
  
  private
  
  def map_exceptions(url)
    begin
      yield
    rescue HTTPClient::ReceiveTimeoutError => original_exc
      exc = HttpClient::NetworkTimeout.new(original_exc.message, :url => url)
      exc.set_backtrace(original_exc.backtrace)
      raise exc
    end
  end
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
