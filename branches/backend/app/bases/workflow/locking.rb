module Workflow
  module Locking
    def lock(remote_url)
      options = {
        :name => remote_url,
        :location => channel.data_provider.name,
        :capacity => 1,
        :timeout => 30.minutes,
        :wait => false,
        :create_resource => true,
      }
      
      if params[:debug]
        debug_callback = lambda do |message|
          debug_print "#{message} for #{remote_url}"
        end
        
        options[:debug_callback] = debug_callback
      end
      
      # validate_not_extracted needs to be in a critical section for each file,
      # otherwise two processes may check e.g. local caches simultaneously
      # and both decide to process the same file.
      #
      # yield is is the critical section because local caches are created
      # by extraction process. if we used special marker files then
      # extraction could be brought outside of the critical section.
      Semaphore::Arbitrator.instance.lock(options) do
        validate_fully_uploaded!(remote_url)
        validate_not_extracted!(remote_url)
        yield
      end
    rescue Semaphore::ResourceBusy
      # someone else is processing the file, do nothing
      if params[:debug]
        debug_print "Lock is busy for #{remote_url}"
      end
      # raise the exception so that driver code can exit the process
      # with appropriate exit code
      raise Workflow::FileExtractionInProgress, "File is being extracted: #{remote_url}"
    end
  end
end
