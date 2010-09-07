module S3Client
  class BaseError < StandardError
  end
  
  class HttpError < BaseError
  end
  
  class NetworkError < BaseError
  end
  
  class Item
    attr_reader :key, :last_modified, :md5, :size
    alias :path :key
    
    def initialize(options)
      @key = options[:key]
      @last_modified = options[:last_modified]
      @md5 = options[:md5]
      @size = options[:size]
    end
    
    class << self
      def etag_to_md5(etag)
        etag.sub(%r(\A"(.+)"\Z), '')
      end
    end
  end
end
