autoload :URI, 'uri'

class S3PrefixSpecification
  attr_reader :bucket, :path
  
  def initialize(bucket, path)
    @bucket, @path = bucket, path
  end
  
  def self.parse_prefix_str(str)
    str.split(':', 2)
  end
  
  # s3n://bucket/path
  def self.parse_uri_str(str)
    uri = URI.parse(str)
    [uri.host, uri.path]
  end
  
  def self.from_prefix_str(str)
    bucket, path = parse_prefix_str(str)
    new(bucket, path)
  end
  
  def self.from_uri_str(str)
    bucket, path = parse_uri_str(str)
    new(bucket, path)
  end
end
