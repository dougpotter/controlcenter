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
  end
end
