module Workflow
  # Base class for workflow errors
  class WorkflowError < StandardError; end
  
  # Another process had begun extracting the requested file.
  # Extraction may be actively proceeding, or the other process
  # may have died but its lock timeout had not yet passed.
  class FileExtractionInProgress < WorkflowError; end
  
  # The file had already been extracted with --once option.
  # This exception is only raised when --once option is given.
  # Without --once, it is possible to extract the same file
  # an arbitrary number of times.
  class FileAlreadyExtracted < WorkflowError; end
  
  # Raised when user requests a specific url to be downloaded
  # and provides date/hour/channel, and the url is actually not
  # in the specified date/hour/channel.
  class FileSpecMismatch < WorkflowError; end
  
  # Attempting to extract partially uploaded files.
  class FileNotReady < WorkflowError; end
  
  # Split verification was requested and failed
  class SplitVerificationFailed < WorkflowError; end
  
  module UserInputParsing
    def parse_hours_specification(hours)
      hours = hours.split(',').map do |hour|
        hour = hour.strip
        unless hour =~ /^\d\d?/
          raise ArgumentError, "Invalid hour value: #{hour}"
        end
        hour = hour.to_i
        if hour < 0 || hour > 23
          raise ArgumentError, "Hour value out of range: #{hour}"
        end
        hour
      end
    end
  end
  
  class << self
    include UserInputParsing
    
    attr_accessor :default_logger
  end
  
  self.default_logger = Logger.new(STDOUT)
  
  class Base
    attr_accessor :logger
    
    def initialize(options={})
      @logger = options[:logger] || Workflow.default_logger
    end
    
    private
    
    def create_http_client(params)
      if params[:http_client]
        http_client_class = HttpClient.const_get(params[:http_client].camelize)
      else
        http_client_class = HttpClient::Curb
      end
      http_client_class.new(
        :http_username => params[:http_username],
        :http_password => params[:http_password],
        :timeout => params[:net_io_timeout],
        :debug => params[:debug],
        :logger => self.logger
      )
    end
    
    def with_process_status(options)
      if @update_process_status
        ProcessStatus.set(options) do
          yield
        end
      else
        yield
      end
    end
    
    def absolute_to_relative_path(root, absolute_path)
      root_len, abs_len = root.length, absolute_path.length
      if abs_len < root_len || absolute_path[0...root_len] != root
        raise ArgumentError, "Absolute path #{absolute_path} is not under #{root}"
      end
      relative_path = absolute_path[root_len...abs_len]
      if relative_path[0] == '/'
        relative_path = relative_path[1...relative_path.length]
      end
      relative_path
    end
    
    # ------
    
    def debug_print(msg)
      logger.debug(self.class.name) { msg }
    end
  end
end
