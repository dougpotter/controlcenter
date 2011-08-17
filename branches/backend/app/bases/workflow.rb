module Workflow
  # Base class for workflow errors
  class WorkflowError < StandardError; end
  
  # Incorrect or missing workflow configuration
  class ConfigurationError < WorkflowError; end
  
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
  
  # Detected a file in data provider channel which is not
  # a valid data provider file for some reason
  class DataProviderFileBogus < WorkflowError; end
  
  # Tried to extract a data provider but the data provider
  # is not in the database
  class DataProviderMissing < WorkflowError; end
  
  class << self
    attr_accessor :default_logger
  end
  
  self.default_logger = Logger.new(STDOUT)
end
