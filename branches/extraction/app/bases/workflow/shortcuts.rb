module Workflow
  module Shortcuts
    class Driver
      def initialize(options)
        @options = options
        @workflow_class = options[:workflow_class]
        @workflow_class ||= "#{options[:data_provider_name]}#{options[:workflow_name]}Workflow".constantize
        @settings = workflow_class.configuration
      end
      
      def discover_and_extract
        with_time do |now|
          with_each_channel do |channel|
            time_points, resolution = determine_time_points(now, channel)
            time_points.each do |(date, hour)|
              params = settings.merge(:date => date, :hour => hour, :channel => channel)
              workflow = workflow_class.new(params.to_hash)
              workflow.run
            end
          end
        end
      end
      
      def extract_discovered
        with_time do |now|
          with_each_channel do |channel|
            time_points, resolution = determine_time_points(now, channel)
            time_points.each do |(date, hour)|
              conditions = {
                :label_date => date,
                :status => [DataProviderFile::DISCOVERED, DataProviderFile::BOGUS],
              }
              if hour
                conditions[:label_hour] = hour
              end
              files = channel.data_provider_files.all(
                :conditions => conditions,
                :order => 'url'
              )
              next if files.empty?
              
              # Do not supply hour here.
              # Akamai files are labeled with the last hour of their range,
              # but for extraction purposes that is never acceptable.
              # Since we specify which files to extract, we may skip the hour
              # check in extraction.
              params = settings.merge(:date => date, :channel => channel)
              workflow = workflow_class.new(params.to_hash)
              files.each do |file|
                begin
                  workflow.extract_if_fully_uploaded(file.url)
                rescue Workflow::FileAlreadyExtracted
                  # ignore
                end
              end
            end
          end
        end
      end
      
      def verify
        with_time do |now|
          with_each_channel do |channel|
            time_points, resolution = determine_time_points(now, channel)
            time_points.each do |(date, hour)|
              params = settings.merge(:date => date, :hour => hour, :channel => channel)
              workflow = workflow_class.new(params.to_hash)
              workflow.check_consistency
            end
          end
        end
      end
      
      private
      
      attr_reader :options, :settings, :workflow_class
      
      def with_time
        # extraction always works in UTC
        # apparently Time.zone does not exist here
        now = Time.now.utc
        yield now
      end
      
      def with_each_channel
        channels.each do |channel|
          yield channel
        end
      end
      
      def data_provider
        @data_provider ||= DataProvider.find_by_name(options[:data_provider_name])
      end
      
      def channels
        @channels ||= data_provider.data_provider_channels.all(:order => 'name')
      end
      
      def determine_time_points(now, channel)
        if resolution = options[:resolution]
          resolution = resolution.to_sym
          unless [:hour, :day].include?(resolution)
            raise ArgumentError, "Invalid resolution: #{resolution}"
          end
        else
          # extract with hourly resolution by default
          resolution = :hour
        end
        
        lookback_from_key = "lookback_from_#{resolution}"
        lookback_to_key = "lookback_to_#{resolution}"
        if prefix = options[:lookback_prefix]
          lookback_from_key = "#{prefix}_#{lookback_from_key}"
          lookback_to_key = "#{prefix}_#{lookback_to_key}"
        end
        lookback_from_key = lookback_from_key.to_sym
        lookback_to_key = lookback_to_key.to_sym
        
        # lookback offset is always applied after lookback is determined
        lookback_offset = options[:lookback_offset] || 0
        
        params = settings.to_hash.merge(options)
        
        if resolution == :hour
          lookback_from_hour = params[lookback_from_key] || channel.lookback_from_hour
          lookback_from_hour += lookback_offset
          lookback_to_hour = params[lookback_to_key] || channel.lookback_to_hour
          lookback_to_hour += lookback_offset
          
          # add one hour to the hours to extract hours in the past.
          # example: if it is now 4:05, a lookback of 0 corresponds to
          # 3:00-4:00 period, which starts at 1 less than current time.
          #
          # do the math here because time arithmetic is more expensive than
          # simple integer arithmetic.
          hours = (-lookback_from_hour - 1)..(-lookback_to_hour - 1)
          
          # assume files in the lookback range are completely uploaded,
          # this is to be replaced by readiness heuristic later.
          times = hours.map do |index|
            # build time from lookback hour
            time = now + index.hours
            
            # convert to date & hour pair for workflow
            [time.strftime('%Y%m%d'), time.hour]
          end
        else
          lookback_from_day = params[lookback_from_key] || channel.lookback_from_hour / 24
          lookback_from_day += lookback_offset
          lookback_to_day = params[lookback_to_key] || channel.lookback_to_hour / 24
          lookback_to_day += lookback_offset
          
          days = (-lookback_from_day - 1)..(-lookback_to_day - 1)
          times = days.map do |index|
            time = now + index.days
            [time.strftime('%Y%m%d')]
          end
        end
        
        [times, resolution]
      end
    end
    
    def extract(options)
      driver = Driver.new(options.merge(
        :workflow_name => 'Extract',
        :resolution => :hour
      ))
      driver.discover_and_extract
    end
    module_function :extract
    
    def extract_late(options)
      driver = Driver.new(options.merge(
        :workflow_name => 'Extract',
        :lookback_prefix => 'late',
        :resolution => :hour
      ))
      driver.extract_discovered
    end
    module_function :extract_late
    
    def extract_very_late(options)
      driver = Driver.new(options.merge(
        :workflow_name => 'Extract',
        :lookback_prefix => 'very_late',
        :resolution => :day
      ))
      driver.extract_discovered
    end
    module_function :extract_very_late
    
    def verify_daily(options)
      driver = Driver.new(options.merge(
        :workflow_name => 'Verify',
        :lookback_from_day => 2,
        :lookback_to_day => 0,
        :resolution => :day
      ))
      driver.verify
    end
    module_function :verify_daily
    
    def verify_hourly(options)
      driver = Driver.new(options.merge(
        :workflow_name => 'Verify',
        :lookback_offset => 2,
        :resolution => :hour
      ))
      driver.verify
    end
    module_function :verify_hourly
    
    def verify_late(options)
      driver = Driver.new(options.merge(
        :workflow_name => 'Verify',
        :lookback_prefix => 'very_late',
        :lookback_offset => 1,
        :resolution => :day
      ))
      driver.verify
    end
    module_function :verify_late
    
    def cleanup(options)
      workflow_class = options[:workflow_class]
      workflow_class ||= "#{options[:data_provider_name]}CleanupWorkflow".constantize
      settings = workflow_class.configuration
      workflow = workflow_class.new(settings.to_hash)
      workflow.cleanup
    end
    module_function :cleanup
  end
end
