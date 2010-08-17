namespace :workflows do
  namespace :clearspring do
    desc 'Discover and extract recently made available clearspring data files'
    task :autorun do
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
  end
end
