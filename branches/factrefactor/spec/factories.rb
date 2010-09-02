Factory.define :campaign do |c|
  c.description  "A Campaign"
  c.sequence(:campaign_code) { |n|  "2LR#{n}" }
  c.partner_id { Factory(:partner).id }
  c.start_time Time.now
  c.end_time Time.now + 3600
end

Factory.define :insertion_order do |i|
  i.description "An Insertion Order"
  i.campaign_id { Factory(:campaign).id }
end

Factory.define :partner do |p|
  p.name  "Webroot"
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
end

Factory.define :remote_placement do |r|
  r.campaign_id {Factory(:campaign).id}
  r.audience_id {Factory(:audience).id}
  r.remote_placement_count 1900
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
