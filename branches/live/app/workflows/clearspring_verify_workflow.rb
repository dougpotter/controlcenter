class ClearspringVerifyWorkflow < Workflow::VerifyBase
  include ClearspringAccess
  
  def initialize(params)
    super(params)
    initialize_params(params)
    @http_client = create_http_client(@params)
    @parser = WebParser.new
    @s3_client = create_s3_client(@params)
  end
  
  private
  
  # returns a subset of our_paths that corresponds to their_path.
  # due to gzip splitting our paths do not necessarily correspond exactly to
  # data source paths. our paths may contain a suffix distinguishing one
  # split file from another
  def bucket_paths_under(our_paths, their_path)
    # need to account for the following case:
    #
    # .../view-us.20100920-0100.1.001.log.gz
    # .../view-us.20100920-0100.10.001.log.gz
    #
    # verifying hour 1 should not use hour 10 files.
    # use a regexp match with \b instead of a simple prefix match
    their_path_prefix = their_path.sub(/\.log\.gz$/, '')
    their_path_regexp = /^#{Regexp.quote(their_path_prefix)}\b/
    our_paths.select do |our_path|
      our_path =~ their_path_regexp
    end
  end
  
  # See comment in Workflow::VerifyBase for how preesnce verification works.
  def compute_criteria_to_check
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
  
  # Returns true if against, which could be a local path or remote url,
  # satisfies criteria, which are comprised of channel, date and hour
  # as requested in invocation.
  #
  # This method is called for every criteria and url pair until each
  # criteria is satisfied or we run out of urls.
  def existence_check_fn(criteria, against)
    File.basename(against).starts_with?(criteria[:prefix])
  end
end
