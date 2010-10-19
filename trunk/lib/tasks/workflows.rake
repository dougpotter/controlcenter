namespace :workflows do
  namespace :clearspring do
    desc 'Discover and extract recently made available clearspring data files'
    task :extract_autorun => :environment do
      # extraction always works in UTC
      # apparently Time.zone does not exist here
      now = Time.now.utc
      
      settings = ClearspringExtractWorkflow.configuration
      data_provider = DataProvider.find_by_name('Clearspring')
      channels = data_provider.channels.all(:order => 'name')
      channels.each do |channel|
        # add one hour to the hours to extract hours in the past.
        # example: if it is now 4:05, a lookback of 0 corresponds to
        # 3:00-4:00 period, which starts at 1 less than current time.
        #
        # do the math here because time arithmetic is more expensive than
        # simple integer arithmetic.
        hours = (-channel.lookback_from_hour - 1)..(- channel.lookback_to_hour - 1)
        
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
          workflow = ClearspringExtractWorkflow.new(options.to_hash)
          workflow.run
        end
      end
    end
    
    desc 'Verifies as much extraction as possible on a daily basis'
    task :verify_daily => :environment do
      now = Time.now.utc
      yesterday = now - 1.day
      date = yesterday.strftime('%Y%m%d')
      
      settings = ClearspringExtractWorkflow.configuration
      data_provider = DataProvider.find_by_name('Clearspring')
      channels = data_provider.channels.all(:order => 'name')
      channels.each do |channel|
        options = settings.merge(:date => date, :channel => channel)
        workflow = ClearspringVerifyWorkflow.new(options.to_hash)
        workflow.check_consistency
      end
    end
    
    desc 'Verifies extraction for hourly updated channels on an hourly basis'
    task :verify_hourly => :environment do
      now = Time.now.utc
      # need to go back based on how far back extract_autorun goes.
      # XXX consider using lookback parameters from channels here
      # to determine which times we should be checking.
      time = now - 8.hours
      date = time.strftime('%Y%m%d')
      hour = time.hour
      
      settings = ClearspringExtractWorkflow.configuration
      data_provider = DataProvider.find_by_name('Clearspring')
      channels = data_provider.channels.all(:order => 'name')
      channels.each do |channel|
        options = settings.merge(:date => date, :hour => hour, :channel => channel)
        workflow = ClearspringVerifyWorkflow.new(options.to_hash)
        workflow.check_consistency
      end
    end
  end
end
