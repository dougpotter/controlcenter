require 'httpclient'
# We use Time.parse, which requires requiring time
require 'time'

class HttpClient::Httpclient < HttpClient::Base
  # allowed options:
  # :http_username
  # :http_password
  # :timeout
  # :debug
  # :logger
  def initialize(options={})
    super(options)
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
    
    map_exceptions(exception_map, url) do
      @client.get_content(url)
    end
  end
  
  def download(url, local_path)
    if @debug
      debug_print "Download #{url} -> #{local_path}"
    end
    
    File.open(local_path, 'w') do |file|
      map_exceptions(exception_map, url) do
        @client.get(url) do |chunk|
          file << chunk
        end
      end
    end
  end
  
  def get_url_content_length(url)
    headers = do_head(url)
    if length = headers['content-length'][0]
      length.to_i
    else
      raise HttpClient::UnsupportedServer, "Content length not found in returned headers"
    end
  end
  
  def get_url_time(url)
    headers = do_head(url)
    if time = headers['last-modified'][0]
      Time.parse(time)
    else
      raise HttpClient::UnsupportedServer, "Last modified not found in returned headers"
    end
  end
  
  private
  
  def do_head(url)
    if @debug
      debug_print "Head #{url}"
    end
    
    map_exceptions(exception_map, url) do
      resp = @client.head(url)
      resp.header
    end
  end
  
  def exception_map
    [
      [HTTPClient::ReceiveTimeoutError, HttpClient::NetworkTimeout],
      [SocketError, HttpClient::NetworkError],
    ]
  end
end
