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
    
    @client.get_content(url)
  end
  
  def download(url, local_path)
    if @debug
      debug_print "Download #{url} -> #{local_path}"
    end
    
    File.open(local_path, 'w') do |file|
      @client.get(url) do |chunk|
        file << chunk
      end
    end
  end
  
  private
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end