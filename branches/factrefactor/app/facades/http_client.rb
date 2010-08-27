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
end
