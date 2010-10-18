class AkamaiVerifyWorkflow < Workflow::VerifyBase
  include AkamaiAccess
  
  def initialize(params)
    super(params)
    initialize_params(params)
    @s3_client = create_s3_client(@params)
  end
  
  private
  
  # There is on splitting being done for akamai logs, so this is a simple
  # equality check.
  def bucket_paths_under(our_paths, their_path)
    our_paths.select { |path| path == their_path }
  end
  
  # See comment in Workflow::VerifyBase for how preesnce verification works.
  def compute_criteria_to_check
    if params[:hour]
      hours = [params[:hour]]
    else
      hours = (0...24).to_a
    end
    criteria = hours.map do |hour|
      {:str => "#{date}#{hour}", :date => date, :hour => hour}
    end
    [criteria, true]
  end
  
  # Organization of files supplied by akamai lags behind changes in
  # update frequency. Therefore at any given time existing files for a
  # channel may not reflect that channel's update frequency.
  #
  # Fortunately, akamai naming scheme is such that each file name definitively
  # indicates the range it covers (in other words it is not just a point
  # inside the range as is the case with clearspring). Therefore we
  # may check whether a particular url set covers the criteria without
  # knowing or using update frequency, either declared or actual, of the
  # respective channel.
  #
  # The difficulty still is the word 'set'; it may be the case that multiple
  # urls cover a single criteria. We work around this issue by splitting a
  # day into hours (in compute_criteria_to_check) and requiring that every
  # hour exists.
  #
  # Because of the preceding paragraph, criteria must always include hour.
  def existence_check_fn(criteria, against)
    regexp = /(\d{8})(\d\d)00-(\d\d)00/
    name = File.basename(against)
    unless regexp =~ name
      raise ArgumentError, "File name does not conform to expected format: #{name}"
    end
    date, start_hour, end_hour = $1, $2, $3
    if date != criteria[:date]
      return false
    end
    start_hour, end_hour = start_hour.to_i, end_hour.to_i
    required_hour = criteria[:hour]
    start_hour <= required_hour && end_hour >= required_hour + 1
  end
end
