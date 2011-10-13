namespace :db do
  desc "Create Partner seed file from partners at appnexus"
  task :appnexus_partners_seed_file => :environment do
    seed_lines = []
    for partner in Partner.all_apn
      seed_lines << "{ :name => \"#{partner["name"]}\", :partner_code => \"#{partner["code"]}\" }"
    end

    File.open(
      File.join(RAILS_ROOT, "db", "fixtures", "partners_from_apn.rb"), "w") do |f|
        f.puts "Partner.seed_many(:partner_code, [\n#{seed_lines * ",\n"}\n])"
    end
  end

  desc "Create Partner seed file from advertisers at Appnexus and add them to "+
    "the database"
  task :seed_appnexus_partners => [ :environment, :appnexus_partners_seed_file] do
    ENV["SEED"] = "partners_from_apn"
    Rake::Task["db:seed_fu"].execute
  end
end
