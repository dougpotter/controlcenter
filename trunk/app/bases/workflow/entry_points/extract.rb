module Workflow
  module EntryPoints
    module Extract
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
    end
  end
end