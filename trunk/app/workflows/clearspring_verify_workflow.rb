class ClearspringVerifyWorkflow < ClearspringExtractWorkflow
  def initialize(params)
    super(params)
    initialize_params(params)
    @http_client = create_http_client(@params)
    @parser = WebParser.new
    @s3_client = create_s3_client(@params)
  end
  
  def check_listing
    data_source_urls = list_data_source_files
    our_paths = list_bucket_files
    have, missing, partial = check_correspondence(data_source_urls, our_paths)
    report_correspondence(have, missing, partial)
    missing.empty? && partial.empty?
  end
  
  def check_consistency
    data_source_urls = list_data_source_files
    have, missing = check_existence(data_source_urls)
    report_existence(have, missing)
    ok = missing.empty?
    
    our_paths = list_bucket_files
    have, missing, partial = check_correspondence(data_source_urls, our_paths)
    report_correspondence(have, missing, partial)
    ok && missing.empty? && partial.empty?
  end
  
  def check_our_existence
    have, missing = find_our_files
    report_existence(have, missing)
    missing.empty?
  end
  
  def check_their_existence
    have, missing = find_their_files
    report_existence(have, missing)
    missing.empty?
  end
  
  private
  
  def find_their_files
    data_source_urls = list_data_source_files
    check_existence(data_source_urls)
  end
  
  def find_our_files
    bucket_paths = list_bucket_files
    check_existence(bucket_paths)
  end
  
  def check_correspondence(data_source_urls, our_paths)
    have, missing, partial = [], [], []
    data_source_urls.each do |url|
      remote_relative_path = url_to_relative_data_source_path(url)
      local_path = build_local_path(remote_relative_path)
      bucket_path = build_s3_path(local_path)
      
      ok = false
      if params[:trust_recorded]
        data_provider_file = DataProviderFile.find_by_url(url)
        if data_provider_file && data_provider_file.status == DataProviderFile::VERIFIED
          have << bucket_path
          ok = true
        end
      end
      
      if !ok
        extracted_paths = bucket_paths_under(our_paths, bucket_path)
        if ok = !extracted_paths.empty?
          if params[:check_sizes]
            source_size = @http_client.get_url_content_length(url)
            items = list_bucket_items
            extracted_items = extracted_paths.map do |path|
              items.detect { |item| item.path == path }
            end
            extracted_size = extracted_items.inject(0) do |sum, item|
              sum + item.size
            end
            if params[:check_sizes_exactly]
              ok = extracted_size == source_size
            else
              difference = (1 - extracted_size.to_f/source_size).abs
              if params[:check_sizes_strictly]
                ok = difference < 0.1
              else
                ok = difference < 0.2
              end
            end
          end
          if ok && params[:check_content]
          end
          if ok
            if params[:record]
              create_data_provider_file(url, DataProviderFile::VERIFIED)
            end
            have << bucket_path
          else
            if params[:record]
              mark_data_provider_file_bogus(url)
            end
            partial << bucket_path
          end
        else
          if params[:record]
            mark_data_provider_file_bogus(url)
          end
          missing << bucket_path
        end
      end
    end
    [have, missing, partial]
  end
  
  def check_existence(items)
    options_list, require_all = compute_prefixes_to_check
    have, missing = [], []
    if require_all
      options_list.each do |options|
        found = items.any? { |item| File.basename(item).starts_with?(options[:prefix]) }
        if found
          have << {:date => options[:date], :hour => options[:hour]}
        else
          missing << {:date => options[:date], :hour => options[:hour]}
        end
      end
    else
      found = options_list.any? do |options|
        items.any? { |item| File.basename(item).starts_with?(options[:prefix]) }
      end
      if found
        have << {:date => options_list.first[:date]}
      else
        missing << {:date => options_list.first[:date]}
      end
    end
    [have, missing]
  end
  
  def report_correspondence(have, missing, partial)
    have.each do |bucket_path|
      puts "Have #{bucket_path}"
    end
    missing.each do |bucket_path|
      STDERR.puts "Missing #{bucket_path}"
    end
    partial.each do |bucket_path|
      STDERR.puts "Partial #{bucket_path}"
    end
  end
  
  def report_existence(have, missing)
    have.each do |options|
      puts "Have #{date_with_hour(options)}"
    end
    missing.each do |options|
      STDERR.puts "Missing #{date_with_hour(options)}"
    end
  end
  
  def list_bucket_items
    @s3_client.list_bucket_items(s3_bucket, build_s3_prefix)
  end
  
  def list_bucket_files
    @s3_client.list_bucket_files(s3_bucket, build_s3_prefix)
  end
  
  # returns a subset of our_paths that corresponds to their_path.
  # due to gzip splitting our paths do not necessarily correspond exactly to
  # data source paths. our paths may contain a suffix distinguishing one
  # split file from another
  def bucket_paths_under(our_paths, their_path)
    their_path_prefix = their_path.sub(/\.log\.gz$/, '')
    our_paths.select do |our_path|
      # this test is a little sketchy but it will work for v1
      our_path[0...their_path_prefix.length] == their_path_prefix
    end
  end
  
  def compute_prefixes_to_check
    if params[:hour]
      hours = [params[:hour]]
      require_all = true
    else
      hours = (0...24).to_a
      require_all = channel.update_frequency == DataProviderChannel::UPDATES_HOURLY
    end
    options_list = hours.map do |hour|
      prefix = basename_prefix(
        :channel_name => channel.name,
        :date => params[:date], :hour => hour
      )
      {:date => params[:date], :hour => hour, :prefix => prefix}
    end
    [options_list, require_all]
  end
  
  def mark_data_provider_file_bogus(file_url)
    # we only want to mark previously verified files as bogus; if a file
    # was not verified, we're not going to change its status.
    # if no record exists for a file, we are not going to create one here
    # either
    DataProviderFile.transaction do
      file = channel.data_provider_files.find_by_url_and_status(file_url, DataProviderFile::EXTRACTED)
      if file
        file.status = dataProviderFile::BOGUS
        file.save!
      end
    end
  end
end
