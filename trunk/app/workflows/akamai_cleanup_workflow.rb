class AkamaiCleanupWorkflow < Workflow::CleanupBase
  include AkamaiAccess
  
  private
  
  # Returns the timestamp of path for cleanup purposes. We take the end
  # of range that the file encompasses.
  def determine_file_time(path)
    date, start_hour, end_hour = date_and_hours_from_path(path)
    # here we assume file timestamps are in UTC
    year, month, day = date[0..3].to_i, date[4..5].to_i, date[6..7].to_i
    # end_hour may be 24, use arithmetic instead of passing end_hour to new
    Time.utc(year, month, day) + end_hour.hours
  end
end
