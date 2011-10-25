def seed_beacon
  br = BEACON_CONFIG["api_root_url"]
  agent = Curl::Easy.new
  fixtures = YAML.load_file(File.join(RAILS_ROOT, 'spec', 'fixtures', 'beacon.yml'))

  audience_ids = []

  for audience in fixtures["audiences"]
    agent.url = "#{br}audiences?"+
    "audience_type=#{audience["type"]}&"+
    "name=#{CGI.escape(audience["name"])}&"+
    "pid=#{audience["pid"]}"
    agent.http_post
    audience_ids << agent.header_str.match(/Location.*\/(\d+)/)[1]
  end

  for load_operation in fixtures["load_operations"]
    agent.url = "#{br}audiences/#{audience_ids[0]}/load_operations?"+
    "audience_id=#{audience_ids[0]}&"+
    "status=#{load_operation["status"]}&"+
    "s3_xguid_list_prefix=#{load_operation["s3_xguid_list_prefix"]}"
    agent.http_post
  end

  for request_condition in fixtures["request_conditions"]
    agent.url = "#{br}audiences/#{audience_ids[1]}/request_conditions?"+
    "audience_id=#{audience_ids[1]}&"+
    "request_url_regex=#{request_condition["request_url_regex"]}&"+
    "referer_url_regex=#{request_condition["referer_url_regex"]}"
    agent.http_post
  end

  for sync_rule in fixtures["sync_rules"]
    agent.url = "#{br}audiences/#{audience_ids[0]}/request_conditions?"+
    "audience_id=#{audience_ids[0]}&"+
    "sync_period=#{sync_rule["sync_period"]}&"+
    "nonsecure_add_pixel=#{sync_rule["nonsecure_add_pixel"]}&"+
    "secure_add_pixel=#{sync_rule["secure_add_pixel"]}&"+
    "secure_remove_pixel=#{sync_rule["secure_remove_pixel"]}&"+
    "nonsecure_remove_pixel=#{sync_rule["nonsecure_remove_pixel"]}"
    agent.http_post
  end
end


