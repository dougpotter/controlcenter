module Workflow
  module ErrorHandling
    # Required options:
    # :retry_count
    # :sleep_time
    # :exception_class or :exception_classes
    # Optional options:
    # :extra_callback
    def retry_errors(options)
      if options[:exception_class] && options[:exception_classes]
        raise ArgumentError, "Cannot specify both :exception_class and :exception_classes"
      end
      exception_classes = options[:exception_classes] || [options[:exception_class]]
      extra_callback = options[:extra_callback]
      0.upto(options[:retry_count]) do |index|
        begin
          return yield
        rescue Interrupt, SystemExit
          raise
        rescue Exception => e
          unless exception_classes.detect { |klass| e.is_a?(klass) }
            raise
          end
          if params[:debug]
            debug_print "Retrying after exception: #{e} (#{e.class}) at #{e.backtrace.first}"
          end
          
          if index == options[:retry_count]
            raise
          else
            if extra_callback
              extra_callback.call(e)
            end
            sleep(options[:sleep_time])
          end
        end
      end
    end
    
    def retry_network_errors(options)
      default_options = {:exception_class => HttpClient::NetworkError}
      retry_errors(default_options.update(options)) do
        yield
      end
    end
    
    def retry_aws_errors(options)
      callback = lambda do |exception|
        http_code = exception.http_code.to_i
        if http_code < 500 || http_code >= 600
          # only retry 5xx errors
          raise
        end
      end
      default_options = {:exception_class => S3Client::HttpError, :extra_callback => callback}
      retry_errors(default_options.update(options)) do
        yield
      end
    end
  end
end
