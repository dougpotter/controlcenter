class ClearspringVerifyWorkflow < ClearspringExtractWorkflow
  def initialize(params)
    initialize_params(params)
    @http_client = create_http_client(@params)
    @parser = WebParser.new
    @s3_client = S3Client::RightAws.new(:debug => @params[:debug])
  end
  
  def check_listing
    data_source_urls = list_data_source_files
    our_paths = list_bucket_items
    data_source_urls.each do |url|
      remote_relative_path = url_to_relative_data_source_path(url)
      local_path = build_local_path(remote_relative_path)
      bucket_path = build_s3_path(local_path)
      if extracted_paths_include?(our_paths, bucket_path)
        puts "Have #{bucket_path}"
      else
        puts "Missing #{bucket_path}"
      end
    end
  end
  
  def check_consistency
  end
  
  def check_our_existence
  end
  
  def check_their_existence
  end
  
  private
  
  def list_bucket_items
    @s3_client.list_bucket_files(s3_bucket)
  end
  
  # due to gzip splitting our paths do not necessarily correspond exactly to
  # data source paths. our paths may contain a suffix distinguishing one
  # split file from another
  def extracted_paths_include?(our_paths, their_path)
    their_path_prefix = their_path.sub(/\.log\.gz$/, '')
    our_paths.any? do |our_path|
      # this test is a little sketchy but it will work for v1
      our_path[0...their_path_prefix.length] == their_path_prefix
    end
  end
end
