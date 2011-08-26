class S3PrefixSpecification
  attr_reader :bucket, :path
  
  def initialize(bucket, path)
    @bucket, @path = bucket, path
  end
  
  def self.parse(str)
    str.split(':', 2)
  end
  
  def self.from_str(str)
    bucket, path = parse(str)
    new(bucket, path)
  end
end
