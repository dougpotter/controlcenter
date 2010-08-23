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
      if our_paths.include?(bucket_path)
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
end
