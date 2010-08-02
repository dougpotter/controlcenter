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
    @curl = Curl::Easy.new
    @curl.userpwd = "#{options[:http_username]}:#{options[:http_password]}"
    if options[:timeout]
      # note: connect_timeout can be overwritten below
      @curl.timeout = @curl.connect_timeout = options[:timeout]
    end
    if options[:connect_timeout]
      @curl.connect_timeout = options[:connect_timeout]
    end
    @debug = options[:debug]
  end
  
  def fetch(url)
    if @debug
      debug_print "Fetch #{url}"
    end
    
    @curl.url = url
    execute
    @curl.body_str
  end
  
  def download(url, local_path)
    if @debug
      debug_print "Download #{url} -> #{local_path}"
    end
    
    File.open(local_path, 'w') do |file|
      old_on_body = @curl.on_body do |data|
        result = old_on_body ? old_on_body.call(data) : data.length
        file << data if result == data.length
        result
      end
      
      @curl.url = url
      execute
      @curl.on_body
    end
  end
  
  private
  
  def execute
    map_exceptions do
      @curl.perform
    end
    check_response
  end
  
  def check_response
    if @curl.response_code != 200
      if @debug
        debug_print "Raising for http code #{@curl.response_code}"
      end
      
      raise HttpClient::HttpError.new(@curl.response_code, @curl.body_str)
    end
  end
  
  def map_exceptions
    begin
      yield
    rescue Curl::Err::TimeoutError => original_exc
      exc = HttpClient::NetworkTimeout.new(original_exc.message)
      exc.set_backtrace(original_exc.backtrace)
      raise exc
    end
  end
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
