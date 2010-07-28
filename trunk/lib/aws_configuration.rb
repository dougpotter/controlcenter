module AwsConfiguration
  class << self
    # AWS access key id
    attr_accessor :access_key_id
    
    # AWS secret access key
    attr_accessor :secret_access_key
  end
  
  self.access_key_id = nil
  self.secret_access_key = nil
end
