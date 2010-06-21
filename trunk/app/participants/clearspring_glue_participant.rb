class ClearspringGlueParticipant < ParticipantBase
  consume :fetch_data_source_url_directory_listing, :sync => true, :require_output_value => true do
    params.input[:remote_url] = params.output.value
  end
  
  consume :parse_directory_listing, :sync => true, :require_output_value => true do
    params.input[:page_text] = params.output.value
  end
  
  consume :absolutize_file_urls, :input => %w(remote_url), :sync => true, :require_output_value => true do
    params.input[:file_urls] = params.output.value.map do |link|
      File.join(params.input[:remote_url], link)
    end
  end
  
  consume :prepare_split_files_for_upload, :sync => true, :require_output_value => true do
    params.input[:local_paths] = params.output.value
  end
  
  consume(:prepare_file_upload, :sync => true, :input => %w(source_path), :require_output_value => true) do
    params.input[:local_path] = params.input[:source_path]
    params.input[:s3_path] = params.output.value
  end
end
