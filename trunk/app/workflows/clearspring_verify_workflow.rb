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
    have, missing = find_their_files
    have.each do |options|
      puts "Have #{date_with_hour(options)}"
    end
    missing.each do |options|
      puts "Missing #{date_with_hour(options)}"
    end
  end
  
  private
  
  def find_their_files
    data_source_urls = list_data_source_files
    options_list, require_all = compute_prefixes_to_check
    have, missing = [], []
    if require_all
      options_list.each do |options|
        found = data_source_urls.any? { |url| File.basename(url).starts_with?(options[:prefix]) }
        if found
          have << {:date => options[:date], :hour => options[:hour]}
        else
          missing << {:date => options[:date], :hour => options[:hour]}
        end
      end
    else
      found = options_list.any? do |options|
        data_source_urls.any? { |url| File.basename(url).starts_with?(options[:prefix]) }
      end
      if found
        have << {:date => options_list.first[:date]}
      else
        missing << {:date => options_list.first[:date]}
      end
    end
    [have, missing]
  end
  
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
  
  def compute_prefixes_to_check
    channel = get_channel!(params[:data_source])
    if params[:hour]
      hours = params[:hour]
      require_all = true
    else
      hours = (0..24).to_a
      require_all = channel.update_frequency == DataProviderChannel::UPDATES_HOURLY
    end
    options_list = hours.map do |hour|
      prefix = basename_prefix(
        :channel_name => params[:data_source],
        :date => params[:date], :hour => hour
      )
      {:date => params[:date], :hour => hour, :prefix => prefix}
    end
    [options_list, require_all]
  end
end
