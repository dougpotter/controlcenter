namespace :workflows do
  namespace :clearspring do
    desc 'Discover and extract recently made available clearspring data files'
    task :extract_autorun do
      # extraction always works in UTC
      # apparently Time.zone does not exist here
      now = Time.now.utc
      
      # assume files over 2 hours old are completely uploaded,
      # this is to be replaced by readiness heuristic later.
      # look back 4 hours
      times = (0...4).map do |index|
        now - 3.hours - index.hours
      end
      
      # convert to date & hour pair for workflow
      times.map! do |time|
        [time.strftime('%Y%m%d'), time.strftime('%H')]
      end
      
      # not the most efficient way of doing it, improve this later
      require 'subprocess'
      times.each do |date, hour|
        script = File.join(File.dirname(__FILE__), '../../script/workflows/clearspring-collect-inline')
        Subprocess.spawn_check([script, '-D', date, '-H', hour])
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
      # need to go back based on how far back extract_autorun goes
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
