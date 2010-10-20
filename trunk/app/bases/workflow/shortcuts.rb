module Workflow
  module Shortcuts
    def extract(options)
      # extraction always works in UTC
      # apparently Time.zone does not exist here
      now = Time.now.utc
      
      workflow_class = options[:workflow_class]
      workflow_class ||= "#{options[:data_provider_name]}ExtractWorkflow".constantize
      settings = workflow_class.configuration
      data_provider = DataProvider.find_by_name(options[:data_provider_name])
      channels = data_provider.data_provider_channels.all(:order => 'name')
      channels.each do |channel|
        lookback_from_hour = options[:lookback_from_hour] || channel.lookback_from_hour
        lookback_to_hour = options[:lookback_to_hour] || channel.lookback_to_hour
        
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
        
        times.each do |date, hour|
          options = settings.merge(:date => date, :hour => hour, :channel => channel)
          workflow = workflow_class.new(options.to_hash)
          workflow.run
        end
      end
    end
    module_function :extract
    
    def verify_daily(options)
      now = Time.now.utc
      yesterday = now - 1.day
      date = yesterday.strftime('%Y%m%d')
      
      workflow_class = options[:workflow_class]
      workflow_class ||= "#{options[:data_provider_name]}VerifyWorkflow".constantize
      settings = workflow_class.configuration
      data_provider = DataProvider.find_by_name(options[:data_provider_name])
      channels = data_provider.data_provider_channels.all(:order => 'name')
      channels.each do |channel|
        options = settings.merge(:date => date, :channel => channel)
        workflow = workflow_class.new(options.to_hash)
        workflow.check_consistency
      end
    end
    module_function :verify_daily
    
    def verify_hourly(options)
      now = Time.now.utc
      # need to go back based on how far back extract_autorun goes.
      # XXX consider using lookback parameters from channels here
      # to determine which times we should be checking.
      lookback = options[:lookback] || 8.hours
      time = now - lookback
      date = time.strftime('%Y%m%d')
      hour = time.hour
      
      workflow_class = options[:workflow_class]
      workflow_class ||= "#{options[:data_provider_name]}VerifyWorkflow".constantize
      settings = workflow_class.configuration
      data_provider = DataProvider.find_by_name(options[:data_provider_name])
      channels = data_provider.data_provider_channels.all(:order => 'name')
      channels.each do |channel|
        options = settings.merge(:date => date, :hour => hour, :channel => channel)
        workflow = workflow_class.new(options.to_hash)
        workflow.check_consistency
      end
    end
    module_function :verify_hourly
  end
end
