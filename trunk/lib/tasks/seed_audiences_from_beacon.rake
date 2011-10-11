namespace :db do
  desc "Create seed file from audiences in beacon.\nIMPORTANT: THIS IS A ONE "+
    "TIME TASK TO BE PERFORMED DURING THE IMPLEMENTATION OF XGCC IN PRODUCTION"
  task :audience_seed_file_from_beacon => :environment do 
    seeds = []
    for audience in Beacon.new.audiences
        seeds << "{ :description => \"#{audience.name}\", "+
        ":audience_code => \"#{Audience.generate_audience_code}\", "+
        ":beacon_id => #{audience["id"]} }"
    end
    seed_string = "# ===========================================================\n"+
      "# THIS IS A POINT IN TIME SEED FILE GENERATED BY THE"+
      "# audience_seed_file_from_beacon\n"+
      "# RAKE TASK CONTAINING ALL BEACON AUDIENCES AT THE TIME THE TASK WAS RUN\n"+
      "# ===========================================================\n"+
      "Audience.seed_many(:audience_code, [\n#{seeds.join(",\n")}\n])"

    File.open(File.join(RAILS_ROOT, "db", "fixtures", ENV["SEED_FILE_NAME"]), 'w') do |f| 
        f.write seed_string
    end
  end
end
