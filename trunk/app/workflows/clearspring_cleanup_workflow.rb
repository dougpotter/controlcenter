class ClearspringCleanupWorkflow < Workflow::CleanupBase
  include ClearspringAccess
  
  def initialize(params)
    super(params)
    initialize_params(params)
  end
  
  def cleanup
    if params[:downloaded]
      cleanup_dir(params[:download_root_dir], params.merge(:age => params[:downloaded_age]))
    end

    if params[:temporary]
      cleanup_dir(params[:temp_root_dir], params.merge(:age => params[:temporary_age]))
    end
  end
  
  private
  
=begin currently not used - was v1
  def determine_file_time(path)
    # use modification time (as opposed to timestamp in file name)
    File.stat(path).mtime
  end
=end
  
  # Returns the timestamp of path for cleanup purposes.
  #
  # Clearspring file names do not encode the range of their content;
  # take the timestamp from the name.
  #
  # XXX how does the timestamp in file name actually correspond to the data
  # in each data file?
  def determine_file_time(path)
    begin
      date, hour = date_and_hour_from_path(path)
    rescue ArgumentError
      if params[:debug]
        debug_print("Unable to determine file time from path: #{path}")
      end
      # XXX this is a moderately evil hack to avoid removing files that
      # do not look like they are part of ETL process.
      # Return current time, assuming only files of some age are removed
      # this file should be kept alone
      return Time.now.utc
    end
    # here we assume file timestamps are in UTC
    year, month, day = date[0..3].to_i, date[4..5].to_i, date[6..7].to_i
    Time.utc(year, month, day, hour)
  end
end
