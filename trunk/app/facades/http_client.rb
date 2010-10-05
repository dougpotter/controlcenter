module HttpClient
  class BaseError < StandardError
    attr_reader :url
    
    def initialize(msg=nil, options={})
      super(msg)
      @url = options[:url]
      @original_exception_class = options[:original_exception_class]
    end
  end
  
  class HttpError < BaseError
    attr_reader :code, :body
    
    def initialize(msg=nil, options={})
      super(msg, options)
      @code, @body = options[:code], options[:body]
    end
  end
  
  class NetworkError < BaseError
  end
  
  class NetworkTimeout < NetworkError
  end
  
  # Keep-alive timeout is technically not an error, but for simplicity
  # we are going to handle it as timeout with the usual retry logic
  class KeepAliveTimeout < NetworkTimeout
  end
  
  class UnsupportedServer < BaseError
  end
end
