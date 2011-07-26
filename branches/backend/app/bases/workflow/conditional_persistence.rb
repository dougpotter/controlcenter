module Workflow
  module ConditionalPersistence
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
    
    # returns true if url is not currently being extracted,
    # and had not been successfully extracted in the past.
    def not_extracted?(url)
      if params[:once]
        !data_provider_file_extracted?(url)
      else
        true
      end
    end
  end
end
