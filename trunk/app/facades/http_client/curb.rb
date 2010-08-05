require 'curb'

class HttpClient::Curb < HttpClient::Base
  # allowed options:
  # :http_username
  # :http_password
  # :timeout
  # :connect_timeout (if :timeout is specified and :connect_timeout is not,
  #   :timeout is used for :connect_timeout as well)
  # :debug
  def initialize(options={})
    @options = options
    create_curl
    @debug = options[:debug]
  end
  
  def fetch(url)
    retried = false
    begin
      if @debug
        debug_print "Fetch #{url}"
      end
      
      execute(url)
      @curl.body_str
    rescue Curl::Err::MultiBadEasyHandle 
      # we get this when earlier request failed and client code retried it
      if retried
        raise
      end
      retried = true
      
      if @debug
        debug_print "Retrying due to Curl::Err::MultiBadEasyHandle"
      end
      
      create_curl
      retry
    end
  end
  
  def download(url, local_path)
    retried = false
    begin
      if @debug
        debug_print "Download #{url} -> #{local_path}"
      end
      
      File.open(local_path, 'w') do |file|
        old_on_body = @curl.on_body do |data|
          result = old_on_body ? old_on_body.call(data) : data.length
          file << data if result == data.length
          result
        end
        
        execute(url)
        @curl.on_body
      end
    rescue Curl::Err::MultiBadEasyHandle 
      # we get this when earlier request failed and client code retried it
      if retried
        raise
      end
      retried = true
      
      if @debug
        debug_print "Retrying due to Curl::Err::MultiBadEasyHandle"
      end
      
      create_curl
      retry
    end
  end
  
  private
  
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
    map_exceptions(url) do
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
  
  def map_exceptions(url)
    begin
      yield
    rescue Curl::Err::TimeoutError => original_exc
      exc = HttpClient::NetworkTimeout.new(original_exc.message, :url => url)
      exc.set_backtrace(original_exc.backtrace)
      raise exc
    rescue IOError => original_exc
      exc = HttpClient::NetworkError.new(original_exc.message, :url => url)
      exc.set_backtrace(original_exc.backtrace)
      raise exc
    end
  end
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
