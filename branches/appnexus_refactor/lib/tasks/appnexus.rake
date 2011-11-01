namespace :appnexus_sandbox do
  desc "Sees AppNexus sandbox with a test advertiser"
  task :seed => :environment do
    object_dir = File.join(RAILS_ROOT, "config", "appnexus", "sandbox_objects")

    # get the test advertiser object if it exists
    agent = Appnexus.new
    test_advertiser = 
      agent.advertiser_by_code(APN_CONFIG[:test_codes][:advertiser])

    # act accordingly, doing nothing if an advetiser already exists or adding one 
    # if a test advertiser does not exist
    if test_advertiser.is_a?(Hash)
      puts "Test advertiser already exists with code #{APN_CONFIG[:test_codes][:advertiser]}"
    else
      
      File.open(File.join(object_dir, "advertiser"), 'r') do |f|
        obj_json = ActiveSupport::JSON.decode(f.read).to_json
        if agent.new_advertiser(obj_json).is_a?(Integer)
          puts "Created advertiser with code "
          "#{APN_CONFIG[:test_codes][:advertiser]}"
        end
      end
    end
  end
end

