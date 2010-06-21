module RuoteConfiguration
  class << self
    # Each of verbose_* options prints debug output to standard error
    # Print HTTP urls fetched
    attr_accessor :verbose_http
    
    # Print job state when jobs start, finish and fail
    attr_accessor :verbose_job_state
    
    # Print job information when jobs are launched
    attr_accessor :verbose_job_launch
    
    # Print job information when waiting for jobs
    attr_accessor :verbose_job_wait
    
    # Print files uploaded to S3
    attr_accessor :verbose_s3
    
    # Use persistent storage.
    # Non-persistent storage is useful when errors spill into following interactive runs
    attr_accessor :use_persistent_storage
  end
  
  self.verbose_http = false
  self.verbose_job_state = false
  self.verbose_job_launch = false
  self.verbose_job_wait = false
  self.verbose_s3 = false
  self.use_persistent_storage = true
end
