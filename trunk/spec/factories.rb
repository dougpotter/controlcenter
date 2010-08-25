Factory.define :campaign do |c|
  c.description  "A Campaign"
  c.sequence(:campaign_code) { |n|  "2LJ#{n}" }
  c.partner_id { Factory(:partner).id }
  c.start_time Time.now
  c.end_time Time.now + 3600
end

Factory.define :partner do |p|
  p.name  "Webroot"
  p.sequence(:partner_code) { |n| 2009 + n }
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
  c.campaign_id {Factory(:campaign).id}
  c.sequence(:creative_code) { |n| "293v#{n}" }
end

Factory.define :ad_inventory_source do |f|
  f.name "name"
  f.sequence(:ais_code) { |n| "Add#{(n+66).chr.upcase}" }
end

Factory.define :model do |m|
  m.description "description"
end

Factory.define :audience do |a|
  a.description "description"
  a.sequence(:audience_code) { |n| "AB#{n}99" }
end

Factory.define :impression_count do |i|
  i.start_time Time.now
  i.end_time Time.now + 60
  i.duration_in_minutes 1
  i.campaign_id {Factory(:campaign).id}
  i.creative_id {Factory(:creative).id}
  i.ad_inventory_source_id {Factory(:ad_inventory_source).id}
  i.audience_id {Factory(:audience).id}
  i.impression_count 10000
end

Factory.define :click_count do |c|
  c.start_time Time.now
  c.end_time Time.now + 60
  c.duration_in_minutes 1
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
