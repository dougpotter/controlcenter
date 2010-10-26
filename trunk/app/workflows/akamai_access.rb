module AkamaiAccess
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include InstanceMethods
    end
  end
  
  module ClassMethods
    def data_provider_name
      'Akamai'
    end
  end
  
  module InstanceMethods
    private
    
    def list_data_source_files
      dir = source_dir_for_channel
      entries = useful_directory_entries(dir)
      absolute_paths = entries.map { |entry| File.join(dir, entry) }
      
      possibly_record_source_urls_discovered(absolute_paths)
      
      absolute_paths.reject! { |path| !should_download_url?(path) }
      absolute_paths
    end
    
    def stat_source(path)
      if params[:debug]
        debug_print "Stat #{path}"
      end
      
      File.stat(path)
    end
    
    def get_source_size(path)
      stat_source(path).size
    end
    
    def get_source_time(path)
      stat_source(path).mtime
    end
    
    # -----
    
    def should_download_url?(path)
      File.basename(path) =~ regexp_to_download
    end
    
    # -----
    
    def channel_parent_subdirs
      %w(logs-by-pid logs-by-type logs-by-host)
    end
    
    def channel_parent_path(subdir)
      File.join(params[:source_dir], subdir)
    end
    
    # -----
    
    # Channel name should be of form subdir/basename
    def source_dir_for_channel(channel=self.channel)
      File.join(params[:source_dir], channel.name)
    end
    
    def build_s3_prefix
      # date is required, it should always be given to workflow.
      "#{channel.name}/raw/#{params[:date]}"
    end
    
    def build_s3_path(local_path)
      filename = File.basename(local_path)
      "#{build_s3_prefix}/#{filename}"
    end
    
    # Builds a regular expression that matches all files that should be
    # downloaded given workflow parameters, and no other files.
    #
    # If hour is given to workflow, the regular expression will match any
    # file covering the hour. The reason for this is that channels which
    # are updated daily are updated at different times in a day, so
    # extracting for example only on hour 0 may cause up to a 23 hour delay
    # if files happen to be uploaded in hour 1.
    def regexp_to_download
      if hour
        # With hour, for hourly updated channels we want files of
        # that hour only, but for daily updated channels we want all files
        # of the day. For channels that are updated every four hours
        # we have to do a little more work.
        daily_match = "#{date}0000-2400"
        four_floor = (hour / 4).to_i * 4
        four_match = "#{date}#{'%02d' % four_floor}00-#{'%02d' % (four_floor + 4)}00"
        hourly_match = "#{date}#{'%02d' % hour}00-#{'%02d' % (hour + 1)}00"
        /(#{daily_match})|(?:#{four_match})|(?:#{hourly_match})/
      else
        # Without hour, we want to get all files for extraction date
        # regardless of channel update frequency.
        /#{date}\d{4}-\d{4}/
      end
    end
    
    def url_to_relative_data_source_path(data_provider_path)
      absolute_to_relative_path(params[:source_dir], data_provider_path)
    end
    
    def data_provider_url_to_bucket_path(data_provider_path)
      local_path = url_to_relative_data_source_path(data_provider_path)
      build_s3_path(local_path)
    end
    
    def determine_label_date_hour_from_data_provider_file(path)
      date, start_hour, end_hour = date_and_hours_from_path(path)
      # Use end hour for now - pretty arbitrary choice at the moment.
      [date, end_hour]
    rescue ArgumentError => exc
      new_message = "Failed to determine label date/hour range from data provider file: #{exc.message}"
      converted_exc = Workflow::BogusDataProviderFile.new(new_message)
      converted_exc.set_backtrace(exc.backtrace)
      raise converted_exc
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
end
