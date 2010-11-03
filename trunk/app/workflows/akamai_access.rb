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
    
    def list_all_data_source_files
      dir = source_dir_for_channel
      entries = useful_directory_entries(dir)
      absolute_paths = entries.map { |entry| File.join(dir, entry) }
      
      possibly_record_source_urls_discovered(absolute_paths)
      
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
    
    # Determines whether path is in requested date and/or hour.
    def should_download_url?(path)
      begin
        date, start_hour, end_hour = date_and_hours_from_path(path)
      rescue ArgumentError
        # not an actual data file
        return false
      end
      
      int_date = Time.parse(date).to_i / 3600
      if hour
        # point in range check
        params_hour = Time.parse(params[:date]).to_i / 3600 + params[:hour]
        
        # note that later endpoint is the closed one
        int_date + start_hour < params_hour &&
          int_date + end_hour >= params_hour
      else
        # range in range check.
        # note that akamai ranges are no bigger than one day,
        # and without hour params range is exactly one day.
        # we therefore may check if akamai range is within params range
        # and not check the inverse.
        file_start = int_date + start_hour
        file_end = int_date + end_hour
        params_start = Time.parse(params[:date]).to_i / 3600
        params_end = params_start + 24
        
        # note that later endpoint is the closed one.
        # note that we need to allow equality on both ends for e.g.
        # the case when the file covers a full day
        params_start <= file_start && params_end >= file_end ||
          params_start <= file_end && params_end >= file_end
      end
    end
    
    # -----
    
    def channel_parent_subdirs
      %w(logs-by-pid logs-by-type logs-by-host)
    end
    
    def channel_parent_path(subdir)
      File.join(params[:data_source_root], subdir)
    end
    
    # -----
    
    # Channel name should be of form subdir/basename
    def source_dir_for_channel(channel=self.channel)
      File.join(params[:data_source_root], channel.name)
    end
    
    def build_s3_prefix
      # date is required, it should always be given to workflow.
      # XXX fragile stuff here
      # XXX qa is lumped with partners
      dirname = File.dirname(channel.name)
      basename = File.basename(channel.name)
      prefix = if dirname == 'logs-by-type'
        "0000-#{basename}/raw-#{basename}"
      else
        "#{basename}/raw"
      end
      "#{prefix}/#{params[:date]}"
    end
    
    def build_s3_path(local_path)
      filename = File.basename(local_path)
      "#{build_s3_prefix}/#{filename}"
    end
    
    def url_to_relative_data_source_path(data_provider_path)
      absolute_to_relative_path(params[:data_source_root], data_provider_path)
    end
    
    def data_provider_url_to_bucket_path(data_provider_path)
      local_path = url_to_relative_data_source_path(data_provider_path)
      build_s3_path(local_path)
    end
    
    def determine_label_date_hour_from_data_provider_file(path)
      begin
        date, start_hour, end_hour = date_and_hours_from_path(path)
      rescue ArgumentError => exc
        new_message = "Failed to determine label date/hour range from data provider file: #{exc.message}"
        converted_exc = Workflow::DataProviderFileBogus.new(new_message)
        converted_exc.set_backtrace(exc.backtrace)
        raise converted_exc
      end
      
      # Akamai log files contain data up to the end hour, so use end hour.
      hour = end_hour
      
      # Akamai end hour may be 24 which is not a valid hour. If hour=24,
      # set hour=0 of the following day.
      if hour == 24
        date = next_day(date)
        hour = 0
      end
      [date, hour]
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
    
    # -----
    
    def next_day(date)
      (Date.parse(date) + 1.day).strftime('%Y%m%d')
    end
    
    def previous_day(date)
      (Date.parse(date) - 1.day).strftime('%Y%m%d')
    end
  end
end
