namespace :workflows do
  namespace :clearspring do
    desc 'Discover and extract recently made available clearspring data files'
    task :extract_autorun => :environment do
      # extraction always works in UTC
      # apparently Time.zone does not exist here
      now = Time.now.utc
      
      channels = DataProviderChannel.all
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
          [time.strftime('%Y%m%d'), time.strftime('%H')]
        end
        
        # not the most efficient way of doing it, improve this later
        # XXX this is now very inefficient
        require 'subprocess'
        times.each do |date, hour|
          script = File.join(File.dirname(__FILE__), '../../script/workflows/clearspring-collect-inline')
          Subprocess.spawn_check([script, '-C', channel.name, '-D', date, '-H', hour])
        end
      end
    end
    
    desc 'Verifies as much extraction as possible on a daily basis'
    task :verify_daily do
      now = Time.now.utc
      yesterday = now - 1.day
      date = yesterday.strftime('%Y%m%d')
      
      # not the most efficient way of doing it, improve this later
      require 'subprocess'
      script = File.join(File.dirname(__FILE__), '../../script/workflows/clearspring-collect-verify')
      Subprocess.spawn_check([script, '-D', date, '--check-consistency'])
    end
    
    desc 'Verifies extraction for hourly updated channels on an hourly basis'
    task :verify_hourly => :environment do
      now = Time.now.utc
      # need to go back based on how far back extract_autorun goes.
      # XXX consider using lookback parameters from channels here
      # to determine which times we should be checking.
      time = now - 8.hours
      date = time.strftime('%Y%m%d')
      hour = time.strftime('%H')
      
      channels = DataProviderChannel.hourly
      
      # not the most efficient way of doing it, improve this later
      require 'subprocess'
      script = File.join(File.dirname(__FILE__), '../../script/workflows/clearspring-collect-verify')
      channels.each do |channel|
        Subprocess.spawn_check([script, '-D', date, '-H', hour, '--check-consistency', '-C', channel.name])
      end
    end
  end
end
