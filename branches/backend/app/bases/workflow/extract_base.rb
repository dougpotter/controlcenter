module Workflow
  # Contains methods common to extract workflows.
  class ExtractBase < Base
    include EntryPoints::Extract
    
    expose_params :channel, :date, :hour, :s3_bucket
    
    class << self
      def not_extracted_check_cost
        # db lookup
        100
      end
    end
    
    private
    
    def validate_source_url_for_extraction!(url)
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
