require 'right_http_connection'

class HttpClient::RightAws < HttpClient::Base
  # allowed options:
  # :http_username
  # :http_password
  # :timeout
  # :connect_timeout (if :timeout is specified and :connect_timeout is not,
  #   :timeout is used for :connect_timeout as well)
  # :debug
  def initialize(options={})
    @http_username, @http_password = options[:http_username], options[:http_password]
    @timeout, @connect_timeout = options[:timeout], options[:connect_timeout]
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
  
  private
  
  def issue_request(url)
    options = {
      :http_connection_read_timeout => @timeout,
      :http_connection_connect_timeout => @timeout,
    }
    if @connect_timeout
      options[:http_connection_connect_timeout] = @connect_timeout
    end
    conn = Rightscale::HttpConnection.new(options)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path)
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
