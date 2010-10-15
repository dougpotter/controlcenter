module Workflow
  module EntryPoints
    def run
      files = list_data_source_files
      # if :once option was given, #extract will raise a workflow error
      # for files that are being extracted elsewhere or that have been already extracted.
      # #run is called to do both discovery and extraction, and should extract all
      # extractable files. therefore we catch and ignore extraction in progress
      # and file already extracted workflow errors
      files.each do |file|
        begin
          extract(file)
        rescue Workflow::FileExtractionInProgress, Workflow::FileAlreadyExtracted
          # igrore
        end
      end
    end
    
    def discover
      list_data_source_files
    end
    
    def extract(file_url)
      perform_extraction(file_url)
    end
  end
end
