module RuoteConfiguration
  class << self
    # Each of verbose_* options prints debug output to standard error
    # Print HTTP urls fetched
    @@verbose_http = false
    attr_accessor :verbose_http
    
    # Print job state when jobs start, finish and fail
    @@verbose_job_state = false
    attr_accessor :verbose_job_state
    
    # Print job information when jobs are launched
    @@verbose_job_launch = false
    attr_accessor :verbose_job_launch
    
    # Print job information when waiting for jobs
    @@verbose_job_wait = false
    attr_accessor :verbose_job_wait
    
    # Print files uploaded to S3
    @@verbose_s3 = false
    attr_accessor :verbose_s3
    
    # Use persistent storage.
    # Non-persistent storage is useful when errors spill into following interactive runs
    @@use_persistent_storage = true
    attr_accessor :use_persistent_storage
  end
end
