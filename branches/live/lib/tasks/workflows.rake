namespace :workflows do
  namespace :akamai do
    desc 'Discover and extract recently uploaded akamai data files'
    task :extract_autorun => :environment do
      Workflow::Shortcuts.extract(
        :data_provider_name => 'Akamai'
      )
    end
    
    desc 'Verifies as much akamai extraction as possible on a daily basis'
    task :verify_daily => :environment do
      Workflow::Shortcuts.verify_daily(
        :data_provider_name => 'Akamai'
      )
    end
    
    desc 'Extract already discovered akamai data files that are uploaded way later than their labeled date'
    task :extract_late => :environment do
      Workflow::Shortcuts.extract_late(
        :data_provider_name => 'Akamai'
      )
    end
    
    desc 'Verifies extraction of recently extracted akamai files'
    task :verify_hourly => :environment do
      Workflow::Shortcuts.verify_hourly(
        :data_provider_name => 'Akamai'
      )
    end
    
    desc 'Removes old akamai files'
    task :cleanup => :environment do
      Workflow::Shortcuts.cleanup(
        :data_provider_name => 'Akamai'
      )
    end
  end
  
  namespace :clearspring do
    desc 'Discover and extract recently made available clearspring data files'
    task :extract_autorun => :environment do
      Workflow::Shortcuts.extract(
        :data_provider_name => 'Clearspring'
      )
    end
    
    desc 'Extract already discovered clearspring data files that are uploaded way later than their labeled date'
    task :extract_late => :environment do
      Workflow::Shortcuts.extract_late(
        :data_provider_name => 'Clearspring'
      )
    end
    
    desc 'Verifies as much clearspring extraction as possible on a daily basis'
    task :verify_daily => :environment do
      Workflow::Shortcuts.verify_daily(
        :data_provider_name => 'Clearspring'
      )
    end
    
    desc 'Verifies extraction for hourly updated clearspring channels on an hourly basis'
    task :verify_hourly => :environment do
      Workflow::Shortcuts.verify_hourly(
        :data_provider_name => 'Clearspring'
      )
    end
  end
end
