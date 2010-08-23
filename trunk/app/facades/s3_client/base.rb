class S3Client::Base
  include ExceptionMappingMixin
  
  # allowed options:
  # :timeout
  # :debug
  def initialize(options={})
    raise NotImplemented
  end
  
  def put_file(bucket, remote_path, local_path)
    raise NotImplemented
  end
  
  def list_bucket_files(bucket)
    raise NotImplemented
  end
  
  private
  
  def debug_print(msg)
    $stderr.puts(msg)
  end
end
