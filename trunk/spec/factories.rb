Factory.define :campaign do |c|
  c.name "A Campaign"
  c.sequence(:campaign_code) { |n|  "2LR#{n}" }
  c.start_time Time.now
  c.end_time Time.now + 3600
  c.line_item_id { Factory(:line_item).id }
end

Factory.define :line_item do |c|
  c.sequence(:line_item_code) { |n| "AB#{n}C" }
  c.name "A Line Item"
  c.start_time  Time.now
  c.end_time Time.now + 3600
  c.partner_id { Factory(:partner).id }
end

Factory.define :partner do |p|
  p.name "Webroot"
  p.sequence(:partner_code) { |n| 2019 + n }
end

Factory.define :creative_size do |c|
  c.sequence(:height) { |n| n + 100 }
  c.sequence(:width) { |n| n + 50 }
  c.common_name "Meaderscraper"
end

Factory.define :creative do |c|
  c.name "creative name"
  c.media_type "media type"
  c.creative_size_id {Factory(:creative_size).id}
  c.sequence(:creative_code) { |n| "294v#{n}" }
end

Factory.define :ad_inventory_source do |f|
  f.name "name"
  f.sequence(:ais_code) { |n| "Adc#{(n+66).chr.upcase}" }
end

Factory.define :model do |m|
  m.description "description"
end

Factory.define :audience do |a|
  a.description "description"
  a.sequence(:audience_code) { |n| "AC#{n}99" }
  a.campaign_id { Factory(:campaign).id }
end

Factory.define :media_purchase_method do |m|
  m.sequence(:mpm_code) { |n| "23k#{n}" }
end

Factory.define :impression_count do |i|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  i.start_time rounded_time
  i.end_time rounded_time + 60.minutes
  i.duration_in_minutes 60
  i.campaign_id {Factory(:campaign).id}
  i.creative_id {Factory(:creative).id}
  i.ad_inventory_source_id {Factory(:ad_inventory_source).id}
  i.audience_id {Factory(:audience).id}
  i.impression_count 10000
  attr_hsh = {
    "audience_id" => 526, 
    "geography_id" => nil, 
    "end_time" => "Wed, 19 Jan 2011 22:00:00 UTC +00:00", 
    "media_purchase_method_id" => nil, 
    "creative_id" => 525, 
    "ad_inventory_source_id" => 525, 
    "campaign_id" => 1049, 
    "click_count" => 1900, 
    "duration_in_minutes" => 60, 
    "start_time" => "Wed, 19 Jan 2011 21:00:00 UTC +00:00" 
  }.to_json
  i.attributes_on_initialize attr_hsh
end

Factory.define :click_count do |c|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  c.start_time rounded_time
  c.end_time rounded_time + 60.minutes
  c.duration_in_minutes 60
  c.campaign_id {Factory(:campaign).id}
  c.creative_id {Factory(:creative).id}
  c.ad_inventory_source_id {Factory(:ad_inventory_source).id}
  c.audience_id {Factory(:audience).id}
  c.click_count 1900
  attr_hsh = {
    "audience_id" => 526, 
    "geography_id" => nil, 
    "end_time" => "Wed, 19 Jan 2011 22:00:00 UTC +00:00", 
    "media_purchase_method_id" => nil, 
    "creative_id" => 525, 
    "ad_inventory_source_id" => 525, 
    "campaign_id" => 1049, 
    "click_count" => 1900, 
    "duration_in_minutes" => 60, 
    "start_time" => "Wed, 19 Jan 2011 21:00:00 UTC +00:00" 
  }.to_json
  c.attributes_on_initialize attr_hsh
end

Factory.define :conversion_count do |c|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  c.start_time rounded_time
  c.end_time rounded_time + 60.minutes
  c.duration_in_minutes 60
  c.campaign_id {Factory(:campaign).id}
  c.conversion_count 2000
end

Factory.define :unique_conversion_count do |u|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  u.start_time rounded_time
  u.end_time rounded_time + 60.minutes
  u.duration_in_minutes 60
  u.campaign_id {Factory(:campaign).id}
  u.unique_conversion_count 1500
end

Factory.define :unique_remote_placement_count do |u|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  u.start_time rounded_time
  u.end_time rounded_time + 60.minutes
  u.duration_in_minutes 60
  u.audience_id {Factory(:audience).id}
  u.unique_remote_placement_count 1000
end

Factory.define :unique_view_through_conversion_count do |f|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  f.start_time rounded_time
  f.end_time rounded_time + 60.minutes
  f.duration_in_minutes 60
  f.campaign_id {Factory(:campaign).id}
  f.creative_id {Factory(:creative).id}
  f.ad_inventory_source_id {Factory(:ad_inventory_source).id}
  f.audience_id {Factory(:audience).id}
  f.unique_view_through_conversion_count 1200
end

Factory.define :remote_placement do |r|
  r.campaign_id {Factory(:campaign).id}
  r.audience_id {Factory(:audience).id}
  r.remote_placement_count 1900
end

Factory.define :media_cost do |f|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  f.start_time rounded_time
  f.end_time rounded_time + 60.minutes
  f.duration_in_minutes 60
  f.partner_id {Factory(:partner).id}
  f.campaign_id {Factory(:campaign).id}
  f.media_purchase_method_id {Factory(:media_purchase_method).id}
  f.audience_id {Factory(:audience).id}
  f.creative_id {Factory(:creative).id}
  f.media_cost 98989
end

Factory.define :unique_click_count do |f|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  f.start_time rounded_time
  f.end_time rounded_time + 60.minutes
  f.duration_in_minutes 60
  f.partner_id {Factory(:partner).id}
  f.campaign_id {Factory(:campaign).id}
  f.media_purchase_method_id {Factory(:media_purchase_method).id}
  f.audience_id {Factory(:audience).id}
  f.creative_id {Factory(:creative).id}
  f.unique_click_count 1000
end

Factory.define :unique_impression_count do |f|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  f.start_time rounded_time
  f.end_time rounded_time + 60.minutes
  f.duration_in_minutes 60
  f.partner_id {Factory(:partner).id}
  f.campaign_id {Factory(:campaign).id}
  f.media_purchase_method_id {Factory(:media_purchase_method).id}
  f.audience_id {Factory(:audience).id}
  f.creative_id {Factory(:creative).id}
  f.unique_impression_count 1005
end

Factory.define :click_through_rate do |f|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  f.start_time rounded_time
  f.end_time rounded_time + 60.minutes
  f.duration_in_minutes 60
  f.campaign_id {Factory(:campaign).id}
  f.media_purchase_method_id {Factory(:media_purchase_method).id}
  f.audience_id {Factory(:audience).id}
  f.creative_id {Factory(:creative).id}
  f.click_through_rate 1005
end

Factory.define :ecpm do |f|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  f.start_time rounded_time
  f.end_time rounded_time + 60.minutes
  f.duration_in_minutes 60
  f.campaign_id {Factory(:campaign).id}
  f.media_purchase_method_id {Factory(:media_purchase_method).id}
  f.audience_id {Factory(:audience).id}
  f.creative_id {Factory(:creative).id}
  f.ecpm 1005
end

Factory.define :ecpc do |f|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  f.start_time rounded_time
  f.end_time rounded_time + 60.minutes
  f.duration_in_minutes 60
  f.campaign_id {Factory(:campaign).id}
  f.media_purchase_method_id {Factory(:media_purchase_method).id}
  f.audience_id {Factory(:audience).id}
  f.creative_id {Factory(:creative).id}
  f.ecpc 1005
end

Factory.define :ecpa do |f|
  t = Time.new
  rounded_time = Time.local(t.year, t.month, t.day, t.hour, t.min/60*60)
  f.start_time rounded_time
  f.end_time rounded_time + 60.minutes
  f.duration_in_minutes 60
  f.campaign_id {Factory(:campaign).id}
  f.media_purchase_method_id {Factory(:media_purchase_method).id}
  f.audience_id {Factory(:audience).id}
  f.creative_id {Factory(:creative).id}
  f.ecpa 1005
end

Factory.define :country do |c|
  c.country_code "US"
  c.name "United States"
end

Factory.define :zip do |z|
  z.sequence(:zip_code) { |n| "105#{sprintf("%02d", n % 100)}" }
  z.regions { [ Factory(:region) ] }
end

Factory.define :region do |r|
  r.region_code "NY"
  r.country { Factory(:country) }
  r.zips { [ Factory(:zip) ] }
  r.msas { [ Factory(:msa) ] }
end

Factory.define :msa do |m|
  m.sequence(:msa_code) { |n| "014#{n}" }
  m.name "New Amsterdam"
  # Can't specify both region.msas and msa.regions
  #m.regions { [ Factory(:region) ] }
end

Factory.define :misfit_fact do |m|
  m.anomaly "campaign_code:AB12"
  m.fact_class "click_count"
  m.fact_attributes { { :campaign_code => "AB12", :another_attribute => "value"} }
end

Factory.define :campaign_inventory_config do |c|
  c.ad_inventory_source_id { Factory(:ad_inventory_source) }
  c.campaign { Factory(:campaign) }
end

Factory.define :creative_inventory_config do |c|
  c.creative_id { Factory(:creative) }
  c.campaign_inventory_config_id { Factory(:campaign_inventory_config) }
end

Factory.define :ad_hoc_source do |a|
  a.sequence(:s3_bucket) { |i| "bucket:/a/path/#{i}/s3" }
  a.load_status "pending"
  a.sequence(:beacon_load_id) { |i| "AB#{i}LKEWMW9" }
end

Factory.define :retargeting_source do |r|
  r.referrer_regex "a\.*regex"
  r.request_regex "another\.*regex"
end
