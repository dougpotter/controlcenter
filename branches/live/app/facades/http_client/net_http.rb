require 'net/http'
require 'uri'

class HttpClient::NetHttp < HttpClient::Base
  include NetHttpMixin
  
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
        resp.read_body do |chunk|
          file << chunk
        end
      end
    end
  end
  
  private
  
  def issue_request(url, options={})
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
    http = Net::HTTP.new(uri.host, uri.port)
    resp = http.request(req)
    case resp
    when Net::HTTPSuccess
      yield resp
    else
      raise HttpClient::HttpError.new(
        "HTTP #{resp.code}",
        :code => resp.code.to_i,
        :body => resp.body,
        :url => url
      )
    end
  end
end
