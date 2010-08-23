module S3Client
  class BaseError < StandardError
  end
  
  class HttpError < BaseError
  end
  
  class NetworkError < BaseError
  end
end
