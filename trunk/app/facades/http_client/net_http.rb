require 'net/http'
require 'uri'

class HttpClient::NetHttp < HttpClient::Base
  # allowed options:
  # :http_username
  # :http_password
  # :timeout
  # :debug
  def initialize(options={})
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
        resp.read_body do |chunk|
          file << chunk
        end
      end
    end
  end
  
  private
  
  def issue_request(url)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path)
    if @http_username && @http_password
      req.basic_auth(@http_username, @http_password)
    end
    http = Net::HTTP.new(uri.host, uri.port)
    resp = http.request(req)
    case resp
    when Net::HTTPSuccess
      yield resp
    else
      raise HttpClient::HttpError.new(resp.code.to_i, resp.body)
    end
  end
end
