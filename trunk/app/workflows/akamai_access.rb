module AkamaiAccess
  private
  
  def list_data_source_files
    dir = source_dir_for_channel
    entries = useful_directory_entries(dir)
    absolute_paths = entries.map { |entry| File.join(dir, entry) }
    
    possibly_record_source_urls_discovered(absolute_paths)
    
    absolute_paths.reject! { |path| !should_download_url?(path) }
    absolute_paths
  end
  
  def get_source_size(path)
    if params[:debug]
      debug_print "Stat #{path}"
    end
    
    File.stat(path).size
  end
  
  # -----
  
  def should_download_url?(path)
    File.basename(path) =~ regexp_to_download
  end
  
  # -----
  
  def source_dir_base
    @source_dir ||= File.join(params[:source_dir], 'logs-by-pid')
  end
  
  # -----
  
  def source_dir_for_channel
    File.join(source_dir_base, channel.name)
  end
  
  def build_s3_prefix
    # date is required, it should always be given to workflow.
    # channel name is pid.
    "#{channel.name}/raw/#{params[:date]}"
  end
  
  def build_s3_path(local_path)
    filename = File.basename(local_path)
    "#{build_s3_prefix}/#{filename}"
  end
  
  def regexp_to_download
    if hour
      # with hour, for hourly updated channels we want files of
      # that hour only, but for daily updated channels we want all files
      # if hour is zero
      if hour == 0
        /#{date}(?:0000-2400|0000-0100)/
      else
        /#{date}#{'%02d' % hour}00-#{'%02d' % (hour + 1)}00/
      end
    else
      # without hour, we want to get all files for extraction date
      # regardless of channel update frequency
      /#{date}\d{4}-\d{4}/
    end
  end
  
  def url_to_relative_data_source_path(data_provider_path)
    absolute_to_relative_path(source_dir_base, data_provider_path)
  end
  
  def data_provider_url_to_bucket_path(data_provider_path)
    local_path = url_to_relative_data_source_path(data_provider_path)
    build_s3_path(local_path)
  end
  
  def date_and_hours_from_path(path)
    name = File.basename(path)
    date_and_hours_from_name(name)
  end
  
  # name should be a file basename.
  def date_and_hours_from_name(name)
    regexp = /(\d{8})(\d\d)00-(\d\d)00/
    unless regexp =~ name
      raise ArgumentError, "File name does not conform to expected format: #{name}"
    end
    date, start_hour, end_hour = $1, $2, $3
    start_hour, end_hour = start_hour.to_i, end_hour.to_i
    [date, start_hour, end_hour]
  end
  
  # -----
  
  # Like Dir#entries but returns only useful entries
  def useful_directory_entries(dir)
    if params[:debug]
      debug_print "List #{dir}"
    end
    
    Dir.entries(dir).reject { |entry| entry == '.' || entry == '..' }.sort
  end
end
