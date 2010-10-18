module Workflow
  # Contains methods common to extract workflows.
  class ExtractBase < Base
    include EntryPoints::Extract
    
    expose_params :channel, :date, :hour, :s3_bucket
    
    private
    
    def validate_source_url_for_extraction!(url)
      unless should_download_url?(url)
        raise Workflow::FileSpecMismatch, "Url does not match download parameters: #{url}"
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
