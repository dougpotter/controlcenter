module ClearspringAccess
  def should_download_url?(url)
    File.basename(url).starts_with?(prefix_to_download)
  end
  
  private
  
  def list_data_source_files
    with_process_status(:action => 'listing files') do
      url = build_data_source_url
      page_text = retry_network_errors(@network_error_retry_options) do
        @http_client.fetch(url + '/')
      end
      files = @parser.parse_any_httpd_file_list(page_text)
      absolute_file_urls = files.map { |file| build_absolute_url(url, file) }
      
      possibly_record_source_urls_discovered(absolute_file_urls)
      
      absolute_file_urls.reject! { |url| !should_download_url?(url) }
      absolute_file_urls
    end
  end
  
  # -----
  
  def build_data_source_url
    "#{params[:data_source_root]}/#{channel.name}"
  end
  
  def build_absolute_url(remote_url, file)
    File.join(remote_url, file)
  end
  
  def prefix_to_download
    basename_prefix(
      :channel_name => channel.name,
      :date => params[:date], :hour => params[:hour]
    )
  end
  
  def basename_prefix(options)
    "#{options[:channel_name]}.#{date_with_hour(options)}"
  end
  
  def url_to_relative_data_source_path(remote_url)
    absolute_to_relative_path(params[:data_source_root], remote_url)
  end
  
  def build_local_path(remote_relative_path)
    File.join(params[:download_root_dir], remote_relative_path)
  end
  
  def data_provider_url_to_bucket_path(data_provider_url)
    remote_relative_path = url_to_relative_data_source_path(data_provider_url)
    local_path = build_local_path(remote_relative_path)
    build_s3_path(local_path)
  end
  
  def build_s3_prefix
    # date is required, it should always be given to workflow
    "#{params[:clearspring_pid]}/v2/raw-#{channel.name}/#{params[:date]}"
  end
  
  def build_s3_path(local_path)
    filename = File.basename(local_path)
    "#{build_s3_prefix}/#{filename}"
  end
end
