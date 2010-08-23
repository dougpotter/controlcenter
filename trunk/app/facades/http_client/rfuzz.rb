require 'rfuzz/client'
require 'uri'
require 'base64'

# Notes:
#
# 1. RFuzz does not support streaming, so downloading buffers the entire
#    response in memory.
# 2. RFuzz does not support specifying timeout(s) for network operations.
# 3. RFuzz does not support https.
# 4. RFuzz does not support keep-alives, and will hang waiting for the server
#    to close the connection unless Connection: close header is manually
#    provided by the user.
# 5. RFuzz insists on being given the query as a hash, and entirely mishandles
#    query strings given as `:query => query_string` without any warning.
# 6. RFuzz does not work on FreeBSD or at all - it appears to expect the
#    network socket to be open when the socket is closed (this is after all
#    available data has been read from the socket).
class HttpClient::Rfuzz < HttpClient::Base
  # Allowed options:
  #
  # :http_username
  # :http_password
  # :debug
  def initialize(options={})
    @http_username, @http_password = options[:http_username], options[:http_password]
    @debug = options[:debug]
  end
  
  def fetch(url)
    if @debug
      debug_print "Fetch #{url}"
    end
    
    issue_request(url) do |resp|
      resp.http_body
    end
  end
  
  def download(url, local_path)
    if @debug
      debug_print "Download #{url} -> #{local_path}"
    end
    
    issue_request(url) do |resp|
      File.open(local_path, 'w') do |file|
        file << resp.http_body
      end
    end
  end
  
  private
  
  def create_client(uri)
    if @client_host != uri.host || @client_port != uri.port
      headers = {'Connection' => 'close'}
      if @http_username
        headers['WWW-Authenticate'] = encode_http_auth(@http_username, @http_password)
      end
      @client = RFuzz::HttpClient.new(uri.host, uri.port, :head => headers)
      @client_host = uri.host
      @client_port = uri.port
    end
    @client
  end
  
  # rfuzz does not handle http authentication
  def encode_http_auth(username, password)
    Base64.encode64("#{username}:#{password}")
  end
  
  def issue_request(url)
    uri = URI.parse(url)
    if uri.scheme != 'http'
      raise NotImplementedError, "Unsupported scheme: #{uri.scheme}"
    end
    @client = create_client(uri)
    resource = uri.path
    if uri.query
      resource += '?' + uri.query
    end
    resp = @client.get(resource)
    case resp.http_status
    when '200'
      yield resp
    else
      raise HttpClient::HttpError.new(resp.http_status.to_i, resp.http_body)
    end
  end
end
