module HttpClient
  class BaseError < StandardError
    attr_reader :url
    
    def initialize(msg=nil, options={})
      super(msg)
      @url = options[:url]
    end
  end
  
  class HttpError < BaseError
    attr_reader :code, :body
    
    def initialize(msg=nil, options={})
      super(msg, options)
      @code, @body = options[:code], options[:body]
    end
  end
  
  class NetworkTimeout < BaseError
  end
  
  class Base
    # allowed options:
    # :http_username
    # :http_password
    # :timeout
    # :connect_timeout (if :timeout is specified and :connect_timeout is not,
    #   :timeout is used for :connect_timeout as well)
    # :debug
    def initialize(options={})
      raise NotImplemented
    end
    
    def fetch(url)
      raise NotImplemented
    end
    
    def download(url, local_path)
      raise NotImplemented
    end
  end
end
