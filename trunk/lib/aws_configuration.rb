module AwsConfiguration
  class << self
    # AWS access key id
    attr_accessor :access_key_id
    
    # AWS secret access key
    attr_accessor :secret_access_key
    
    # s3.amazonaws.com or local fakes3 instance
    attr_accessor :s3_host
    
    # 80 or 443 (default is 443)
    attr_accessor :s3_port
    
    # http or https (default is https)
    attr_accessor :s3_protocol
  end
  
  self.access_key_id = nil
  self.secret_access_key = nil
  self.s3_host = 's3.amazonaws.com'
  self.s3_port = 443
  self.s3_protocol = 'https'
end
