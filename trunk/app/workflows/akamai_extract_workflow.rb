require 'find'

class AkamaiExtractWorkflow < Workflow::ExtractBase
  class << self
    def default_config_path
      YamlConfiguration.absolutize('workflows/akamai')
    end
    
    def configuration(options={})
      default_options = {:config_path => default_config_path}
      Workflow::Configuration.new(default_options.update(options))
    end
  end
  
  def initialize(params)
    super(params)
    initialize_params(params)
    @s3_client = create_s3_client(@params)
  end
  
  def discover_channels
    entries = useful_directory_entries(source_dir_base)
    # XXX should we raise an exception when an entry is not an integer?
    pids = entries.map { |entry| entry.to_i }.reject { |pid| pid <= 0 }
    
    if pids.empty?
      # XXX should we raise an exception here?
      # when would logs be legitimately empty?
      return
    end
    
    # Postgres cannot test X in (Y) if X is a string and Y is an integer;
    # channel names are strings.
    # Also, int in ints test ought to be quicker than string in strings.
    # Convert name to int then.
    name_as_int = SqlGenerator.cast_to_int('name')
    # XXX assuming this exists
    # XXX should we move the name elsewhere?
    # Note: we do not want to invoke channels on provider which is global,
    # otherwise those channels would not be garbage collected until
    # ruby process exits.
    provider = DataProvider.find_by_name('Akamai')
    # XXX need to select names only
    channels = provider.data_provider_channels.all(
      :conditions => ["#{name_as_int} in (?)", pids]
    )
    existing_pids = channels.map { |channel| channel.name.to_i }
    
    new_pids = pids.reject do |pid|
      # XXX building a hash may be quicker
      existing_pids.include?(pid)
    end
    
    unless new_pids.empty?
      DataProviderChannel.transaction do
        new_pids.each do |pid|
          if params[:debug]
            debug_print("Add #{pid}")
          end
          
          channel = provider.data_provider_channels.build(
            :name => pid,
            # TODO revise lookback hours as appropriate
            :lookback_from_hour => 1,
            :lookback_to_hour => 0
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
  
  def list_data_source_files
    dir = source_dir_for_channel
    entries = useful_directory_entries(dir)
    absolute_paths = entries.map { |entry| File.join(dir, entry) }
    
    possibly_record_source_urls_discovered(absolute_paths)
    
    absolute_paths.reject! { |path| !should_download_url?(path) }
    absolute_paths
  end
  
  # -----
  
  def should_download_url?(path)
    true
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
  
  # -----
  
  # Like Dir#entries but returns only useful entries
  def useful_directory_entries(dir)
    Dir.entries(dir).reject { |entry| entry == '.' || entry == '..' }
  end
end
