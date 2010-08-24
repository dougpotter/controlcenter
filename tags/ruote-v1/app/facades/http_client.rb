require 'curb'

class HttpClient
  # allowed options:
  # :http_username
  # :http_password
  # :debug
  def initialize(options={})
    @curl = Curl::Easy.new
    @curl.userpwd = "#{options[:http_username]}:#{options[:http_password]}"
    @debug = options[:debug]
  end
  
  def fetch(url)
    if @debug
      debug_print "Fetch #{url}"
    end
    
    @curl.url = url
    @curl.perform
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
      @curl.perform
      @curl.on_body
    end
  end
  
  private
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
