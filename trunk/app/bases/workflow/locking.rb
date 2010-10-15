module Workflow
  module Locking
    def self.included(base)
      base.class_eval do
        alias_method_chain :extract, :optional_locking
      end
    end
    
    def extract_with_optional_locking(file_url)
      if params[:lock]
        extract_with_locking(file_url)
      else
        extract_without_locking(file_url)
      end
    end
    
    def extract_with_locking(file_url)
      lock(file_url) do
        extract_without_locking(file_url)
      end
    end
    
    def extract_without_locking(file_url)
      perform_extraction(file_url)
    end
    
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
      
      # ok_to_extract? needs to be in a critical section for each file,
      # otherwise two processes may check e.g. local caches simultaneously
      # and both decide to process the same file.
      #
      # yield is is the critical section because local caches are created
      # by extraction process. if we used special marker files then
      # extraction could be brought outside of the critical section.
      Semaphore::Arbitrator.instance.lock(options) do
        unless fully_uploaded?(remote_url)
          raise Workflow::FileNotReady, "File is not ready to be extracted: #{remote_url}"
        end
        if ok_to_extract?(remote_url)
          yield
        else
          if params[:debug]
            debug_print "File is already extracted: #{remote_url}"
          end
          raise Workflow::FileAlreadyExtracted, "File is already extracted: #{remote_url}"
        end
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
