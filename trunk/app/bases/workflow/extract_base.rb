module Workflow
  # Contains methods common to extract workflows.
  class ExtractBase < Base
    def channel
      params[:channel]
    end
    
    def date
      params[:date]
    end
    
    def hour
      params[:hour]
    end
    
    def s3_bucket
      params[:s3_bucket]
    end
    
    private
    
    # Record source urls as discovered if :record option was given to workflow.
    def possibly_record_source_urls_discovered(urls)
      if params[:record]
        urls.each do |url|
          note_data_provider_file_discovered(url)
        end
      end
    end
    
    # Record source url as extracted if :once option was given to workflow.
    def possibly_record_source_url_extracted(url)
      # See the comment in create_data_provider_file regarding mixing locked
      # and non-locked runs. Status files are only created for once runs
      # (which are also locked).
      if params[:once]
        create_data_provider_file(url) do |file|
          file.status = DataProviderFile::EXTRACTED
          file.extracted_at = Time.now.utc
        end
      end
    end
    
    # returns true if remote_url is not currently being extracted,
    # and had not been successfully extracted in the past.
    def ok_to_extract?(remote_url)
      if params[:once] and already_extracted?(remote_url)
        false
      else
        true
      end
    end
    
    # -----
    
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
