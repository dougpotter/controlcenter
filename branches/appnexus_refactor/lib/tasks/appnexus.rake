namespace :appnexus_sandbox do
  desc "Sees AppNexus sandbox with a test advertiser"
  task :seed => :environment do
    object_dir = File.join(RAILS_ROOT, "config", "appnexus", "sandbox_objects")

    # get the test advertiser object if it exists
    agent = AppnexusClient::API.new_agent
    agent.url = APN_CONFIG["api_root_url"] + "advertiser?code=#{APN_CONFIG[:test_codes][:advertiser]}"
    agent.http_get


    # act accordingly, doing nothing if an advetiser already exists or adding one 
    # if a test advertiser does not exist
    if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
      puts "Test advertiser already exists with code #{APN_CONFIG[:test_codes][:advertiser]}"
    else
      agent.url = APN_CONFIG["api_root_url"] + "advertiser"
      
      File.open(File.join(object_dir, "advertiser"), 'r') do |f|
        obj_json = ActiveSupport::JSON.decode(f.read).to_json
        agent.post_body = obj_json
        agent.http_post
      end
      if ActiveSupport::JSON.decode(agent.body_str)["response"]["status"] == "OK"
        puts "Created advertiser with code #{APN_CONFIG[:test_codes][:advertiser]}"
      end
    end
  end
end

