class AkamaiExtractWorkflow < Workflow::ExtractBase
  include AkamaiAccess
  
  def initialize(params)
    super(params)
    initialize_params(params)
    @s3_client = create_s3_client(@params)
  end
  
  def discover_channels
    channel_parent_subdirs.each do |subdir|
      path = channel_parent_path(subdir)
      if File.exist?(path)
        discover_channels_in_subdir(subdir, path)
      end
    end
  end
  
  def discover_channels_in_subdir(subdir, path)
    entries = useful_directory_entries(path)
    
    if entries.empty?
      # Not all subdirectories have channels. For example, logs-by-host
      # is only used by QA environment, and QA does not have any other logs.
      return
    end
    
    channel_names = entries.map do |entry|
      File.join(subdir, entry)
    end
    
    # XXX assuming this exists
    # XXX should we move the name elsewhere?
    # Note: we do not want to invoke channels on provider which is global,
    # otherwise those channels would not be garbage collected until
    # ruby process exits.
    provider = DataProvider.find_by_name('Akamai')
    # XXX need to select names only
    channels = provider.data_provider_channels.all(
      :conditions => ["name in (?)", channel_names]
    )
    existing_names = channels.map { |channel| channel.name }
    
    new_names = channel_names.reject do |name|
      # XXX building a hash may be quicker
      existing_names.include?(name)
    end
    
    unless new_names.empty?
      DataProviderChannel.transaction do
        new_names.each do |name|
          if params[:debug]
            debug_print("Add #{name}")
          end
          
          channel = provider.data_provider_channels.build(
            :name => name,
            # Akamai channels may lag significantly behind their timestamp
            :lookback_from_hour => 12,
            :lookback_to_hour => 1
          )
          channel.save!
        end
      end
    end
  end
  
  def perform_extraction(source_path)
    validate_source_url_for_extraction!(source_path)
    upload(source_path, s3_bucket, build_s3_path(source_path))
    
    possibly_record_source_url_extracted(source_path)
  end
  
  private
  
  # -----
  
  # Readiness heuristic - for now we consider a file to be fully uploaded
  # if it was modified over 2 hours ago.
  def fully_uploaded?(path)
    get_source_time(path)
  end
end
