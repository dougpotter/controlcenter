class S3Client::Base
  include ExceptionMappingMixin
  
  attr_accessor :logger
  
  # allowed options:
  # :timeout
  # :debug
  # :logger
  def initialize(options={})
    @logger = options[:logger] || Workflow.default_logger
  end
  
  def put_file(bucket, remote_path, local_path)
    raise NotImplemented
  end
  
  def list_bucket_files(bucket)
    raise NotImplemented
  end
  
  private
  
  def debug_print(msg)
    logger.debug(self.class.name) { msg }
  end
end
