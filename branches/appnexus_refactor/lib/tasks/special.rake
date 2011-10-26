namespace :special do
  desc 'Adds name_date to data provider files'
  task :add_name_date => :environment do
    if DataProviderFile.count(:conditions => ['name_date is null']) > 0
      DataProviderFile.transaction do
        DataProviderFile.find_each(:conditions => ['name_date is null']) do |file|
          if file.url =~ /(\d{8})(\d\d)00-(\d\d)00/
            file.name_date = $1
            file.save!
          elsif file.url =~ /\.(\d{8})-(\d\d)00\./
            file.name_date = $1
            file.save!
          end
        end
      end
    end
  end
end
