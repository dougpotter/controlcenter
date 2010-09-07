require 'curb'

class HttpClient::Curb < HttpClient::Base
  # allowed options:
  # :http_username
  # :http_password
  # :timeout
  # :connect_timeout (if :timeout is specified and :connect_timeout is not,
  #   :timeout is used for :connect_timeout as well)
  # :debug
  # :logger
  def initialize(options={})
    super(options)
    @options = options
    create_curl
    @debug = options[:debug]
  end
  
  def fetch(url)
    retry_multi_bad_easy_handle do
      if @debug
        debug_print "Fetch #{url}"
      end
      
      execute(url)
      @curl.body_str
    end
  end
  
  def download(url, local_path)
    retry_multi_bad_easy_handle do
      if @debug
        debug_print "Download #{url} -> #{local_path}"
      end
      
      File.open(local_path, 'w') do |file|
        begin
          old_on_body = @curl.on_body do |data|
            result = old_on_body ? old_on_body.call(data) : data.length
            file << data if result == data.length
            result
          end
          
          execute(url)
        ensure
          @curl.on_body
        end
      end
    end
  end
  
  def get_url_content_length(url)
    retry_multi_bad_easy_handle do
      if @debug
        debug_print "Head #{url}"
      end
      
      @curl.head = true
      execute(url)
      
      # curb is pretty pathetic - we have to parse headers ourselves.
      # hack this
      if /^content-length:\s+(\d+)/ =~ @curl.header_str.downcase
        content_length = $1.to_i
      else
        raise HttpClient::UnsupportedServer, "Content length not found in returned headers"
      end
      content_length
    end
  end
  
  private
  
  def retry_multi_bad_easy_handle
    retried = false
    begin
      yield
    rescue Curl::Err::MultiBadEasyHandle => e
      # we get this when earlier request failed and client code retried it
      if retried
        raise
      end
      retried = true
      
      if @debug
        debug_print "Retrying due to Curl::Err::MultiBadEasyHandle at #{e.backtrace.first}"
      end
      
      create_curl
      retry
    end
  end
  
  def create_curl
    @curl = Curl::Easy.new
    @curl.userpwd = "#{@options[:http_username]}:#{@options[:http_password]}"
    if @options[:timeout]
      # note: connect_timeout can be overwritten below
      @curl.timeout = @curl.connect_timeout = @options[:timeout]
    end
    if @options[:connect_timeout]
      @curl.connect_timeout = @options[:connect_timeout]
    end
  end
  
  def execute(url)
    @curl.url = url
    map_exceptions(exception_map, url) do
      @curl.perform
    end
    check_response(url)
  end
  
  def check_response(url)
    if @curl.response_code != 200
      if @debug
        debug_print "HTTP code #{@curl.response_code} for #{url}"
      end
      
      raise HttpClient::HttpError.new("HTTP #{@curl.response_code}",
        :code => @curl.response_code,
        :body => @curl.body_str,
        :url => url)
    end
  end
  
  def exception_map
    [
      [Curl::Err::TimeoutError, HttpClient::NetworkTimeout],
      [IOError, HttpClient::NetworkError],
      # DNS can be flaky
      [Curl::Err::HostResolutionError, HttpClient::NetworkError],
    ]
  end
end
