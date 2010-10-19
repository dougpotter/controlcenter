class ClearspringCleanupWorkflow < Workflow::CleanupBase
  include ClearspringAccess
  
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
    date, hour = date_and_hour_from_path(path)
    # here we assume file timestamps are in UTC
    year, month, day = date[0..3].to_i, date[4..5].to_i, date[6..7].to_i
    Time.utc(year, month, day, hour)
  end
end
