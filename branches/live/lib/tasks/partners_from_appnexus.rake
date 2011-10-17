namespace :db do
  desc "Create each partner present at Appnexus in XGCC"
  task :seed_appnexus_partners => :environment do
    seed_lines = []
    for partner in Partner.all_apn
      Partner.find_or_create_by_partner_code(
        :name => partner["name"], 
        :partner_code => partner["code"])
    end
  end
end
