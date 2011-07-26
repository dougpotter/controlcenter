module Workflow
  # Contains methods common to extract workflows.
  class ExtractBase < Base
    include EntryPoints::Extract
    
    expose_params :channel, :date, :hour, :s3_bucket
    
    def initialize(params)
      super(params)
      
      # We have up to 3 checks performed on each url before extracting it:
      # 1. Whether the url matches requested parameters (always done)
      # 2. Whether the url has been fully uploaded (always done)
      # 3. Whether the url has been already extracted ("once" mode only)
      #
      # Without locking (and "once" mode implies locking, thus only two
      # first checks remain) the checks should be doen in the order of
      # least expensive to most expensive.
      #
      # With locking some checks have to be done under the lock, and doing
      # them outside of the lock means they would have to be done again
      # under the lock. Notably this applies to the already extracted check.
      #
      # Also with locking, the idea is to get higher concurrency. If a check
      # is expensive (i.e., more expensive than locking) then we want to
      # perform it under the lock even if it does not need to be performed
      # under the lock, to avoid doing it unnecessarily on files that are
      # being worked on by someone else.
      #
      # Conversely, if a check which must be done under the lock is
      # significantly cheaper than locking, it may be worthwile to perform it
      # twice to avoid unnecessarily locking files that cannot be extracted.
      
      if params[:lock]
        @unlocked_checks = []
        @locked_checks = []
        
        if params[:once]
          if self.class.not_extracted_check_cost < self.class.lock_cost
            @unlocked_checks << :not_extracted
          end
          @locked_checks << :not_extracted
        end
        
        if self.class.fully_uploaded_check_cost < self.class.lock_cost
          @unlocked_checks << :fully_uploaded
        else
          @locked_checks << :fully_uploaded
        end
        
        @locked_checks.sort! do |a, b|
          self.class.send("#{a}_check_cost") <=> self.class.send("#{b}_check_cost")
        end
      else
        @unlocked_checks = [:fully_uploaded]
      end
      
      @unlocked_checks.sort! do |a, b|
        self.class.send("#{a}_check_cost") <=> self.class.send("#{b}_check_cost")
      end
    end
    
    class << self
      def not_extracted_check_cost
        # db lookup
        100
      end
      
      def lock_cost
        # two db lookups
        150
      end
    end
    
    private
    
    def validate_should_download_url!(url)
      unless should_download_url?(url)
        raise Workflow::FileSpecMismatch, "Url does not match download parameters: #{url}"
      end
    end
    
    def validate_fully_uploaded!(url)
      unless fully_uploaded?(url)
        raise Workflow::FileNotReady, "File is not ready to be extracted: #{url}"
      end
    end
    
    def validate_not_extracted!(url)
      unless not_extracted?(url)
        if params[:debug]
          debug_print "File is already extracted: #{url}"
        end
        raise Workflow::FileAlreadyExtracted, "File is already extracted: #{url}"
      end
    end
    
    # -----
    
    # Unlike downloading, uploading is common to all data sources.
    # As of this writing.
    def upload(local_path, s3_bucket, s3_path)
      with_process_status(:action => "uploading #{File.basename(local_path)}") do
        retry_network_errors(@network_error_retry_options) do
          retry_aws_errors(@network_error_retry_options) do
            @s3_client.put_file(s3_bucket, s3_path, local_path)
          end
        end
      end
    end
  end
end
