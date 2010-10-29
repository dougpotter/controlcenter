class AkamaiCleanupWorkflow < Workflow::CleanupBase
  include AkamaiAccess
  
  def initialize(params)
    super(params)
    initialize_params(params)
  end
  
  # Cleanup only known channels.
  #
  # We do not extract files from channels we do not know about, therefore
  # removing files from such channels could be a very bad idea.
  def cleanup
    data_provider = Workflow::Invocation.lookup_data_provider(self.class.data_provider_name)
    channels = data_provider.data_provider_channels.all(:order => 'name')
    channels.each do |channel|
      dir = source_dir_for_channel(channel)
      # XXX ugly hack to get cleanup functional for initial release.
      # What should happen is a separate workflow should be instantiated
      # for every channel, like all other workflows work.
      @params[:channel] = channel
      cleanup_dir(dir, params)
    end
  end
  
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
