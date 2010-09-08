require 'right_http_connection'

class HttpClient::RightAws < HttpClient::Base
  # allowed options:
  # :http_username
  # :http_password
  # :timeout
  # :debug
  # :logger
  def initialize(options={})
    super(options)
    @http_username, @http_password = options[:http_username], options[:http_password]
    @timeout = options[:timeout]
    @debug = options[:debug]
  end
  
  def fetch(url)
    if @debug
      debug_print "Fetch #{url}"
    end
    
    issue_request(url) do |resp|
      resp.body
    end
  end
  
  def download(url, local_path)
    if @debug
      debug_print "Download #{url} -> #{local_path}"
    end
    
    issue_request(url) do |resp|
      File.open(local_path, 'w') do |file|
        # right http connection breaks read_body
        file << resp.body
      end
    end
  end
  
  def get_url_content_length(url)
    if @debug
      debug_print "Head #{url}"
    end
    
    issue_request(url, :method => :head) do |resp|
      if length = resp['content-length']
        length.to_i
      else
        raise HttpClient::UnsupportedServer, "Content length not found in returned headers"
      end
    end
  end
  
  private
  
  def issue_request(url, options={})
    options = {
      :http_connection_read_timeout => @timeout,
      :http_connection_connect_timeout => @timeout,
    }
    conn = Rightscale::HttpConnection.new(options)
    uri = URI.parse(url)
    if options[:method] == :head
      request_class = Net::HTTP::Head
    else
      request_class = Net::HTTP::Get
    end
    req = request_class.new(uri.path)
    if @http_username && @http_password
      req.basic_auth(@http_username, @http_password)
    end
    options = {
      :server => uri.host,
      :port => uri.port,
      # right http connection does this, so we don't have to:
      #:protocol => (uri.port == 443 ? 'https' : 'http'),
      :request => req,
    }
    resp = conn.request(options)
    case resp
    when Net::HTTPSuccess
      yield resp
    else
      raise HttpClient::HttpError.new(resp.code.to_i, resp.body)
    end
  end
end
