Given /^the following campaigns:$/ do |campaigns|
  for hash in campaigns.hashes
    hash["line_item_id"] = LineItem.find_by_line_item_code(
      hash.delete("line_item_code")
    ).id
    Campaign.create!(hash)
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) campaign$/ do |pos|
  visit campaigns_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following campaigns:$/ do |expected_campaigns_table|
  expected_campaigns_table.diff!(tableish('table tr', 'td,th'))
end

When /^I check sync checkbox "([^"]*)"$/ do |ais|
  field = "aises_for_sync_"
  check(field)
end

Given /^the standard ais, partner, line item, audience, creative size setup exists$/ do
  When "the following ad_inventory_sources:", table(%{
    |  ais_code |       name         |   
    |    AdX    | Google Ad Exchange |
    |    ApN    |      AppNexus      |   
  })
  When "the following partners:", table(%{
    | partner_code | name |
    |     77777    | Ford |
  })
  When "the following line_items:", table(%{
    | line_item_code |    name     | partner_code |
    |     ABC1       | Ford Spring |    77777     |   
  })
  When "the following audiences:", table(%{
    | audience_code |   description  |
    |      HNXT     | Ford Connected |
  })
  When "the following creative sizes:", table(%{
    | height | width |   common_name   |
    |  250   |  300  |     Medium      |
    |  90    |  728  |   Leaderboard   |
    |  600   |  160  | Wide Skyscraper |
  })
  When "the following ad_hoc_sources:", table(%{
    |     s3_bucket    | load_status | beacon_load_id |
    | bucket:/a/bucket |   pending   |     ABCNID     |
  })
  When "the line item \"ABC1\" is associated with partner \"77777\""
end

Given /^I fill in ad-hoc campaign information$/ do
  When "I select \"Ford Spring\" from \"Line Item\""
  When "I select \"Ad-Hoc\" from \"Audience Type\""
  And "I fill in the following:", table(%{
    | Campaign Name | A New Campaign for Ford |
    | Campaign Code | ANB6 |
    | S3 Bucket | bucket:/a/path/in/s3 |
    | Audience Code | HNXT |
    | Audience Name | An Audience for Ford |
  })
end

Given /^the standard ad-hoc campaign and associated entities exist$/ do
  When "the standard ais, partner, line item, audience, creative size setup exists"
  Given "the following campaigns:", table(%{
    |      name      | campaign_code | line_item_code | campaign_type |  start_time |   end_time  |
    |  Ford Campaign |     ACODE     |     ABC1       |    Ad-Hoc     | "4/20/2000" | "6/20/2000" |
  })

  When "the audience \"HNXT\" is associated with ad-hoc source \"bucket:/a/bucket\""
  When "the campaign \"ACODE\" is related to audience \"HNXT\""
  When "the campaign \"ACODE\" is related to line item \"ABC1\""
  When "campaign \"ACODE\" is associated with ais \"ApN\""
  When "campaign \"ACODE\" has segment id \"123\" on ais \"ApN\""
end

Given /^the secondary ad\-hoc campaign and associated entities exist$/ do
  When "the following partners:", table(%{
    | partner_code |   name  |
    |     22222    | Shamwow |
  })
  When "the following line_items:", table(%{
    | line_item_code |      name      | partner_code |
    |     ABC2       | Shamwow Spring |    22222     |   
  })
  When "the following campaigns:", table(%{
    |       name       | campaign_code | line_item_code | campaign_type |
    | Shamwow Campaign |     BCODE     |     ABC2       |    Ad-Hoc     |
  })
  When "the campaign \"BCODE\" is related to line item \"ABC2\""
end

Given /^campaign "([^"]*)" is associated with audience "([^"]*)"$/ do |campaign_code, audience_code|
  @campaign = Campaign.find_by_campaign_code(campaign_code)
  @campaign.audience = Audience.find_by_audience_code(audience_code)
  @campaign.save!
end

def english_to_integer(english)
  # NOTE: 0 indexed
  case english
  when "first"
    0
  when "second"
    1
  when "third" 
    2
  else
    throw "#{english} not recognized as a plain english representation of a number"
  end
end

def populate_creative_form(default_overrides)
  #sensible defaults
  attrs = {
    :number => 0,
    :creative_code => "ACODE",
    :name => "fall medium",
    :media_type => "flash",
    :landing_page_url => "http://xcdn.com/whatever",
    :size => "90 x 728",
    :image => "logo.png"
  }

  attrs.update(default_overrides)
  
  When "I fill in the following:", table(%{
    | creatives_#{attrs[:number]}_creative_code    | #{attrs[:creative_code]}#{attrs[:number]}   |   
    | creatives_#{attrs[:number]}_name             | #{attrs[:name]}            |
    | creatives_#{attrs[:number]}_media_type       | #{attrs[:media_type]}      |
    | creatives_#{attrs[:number]}_landing_page_url | #{attrs[:landing_page_url]}|
  })
  When "I select \"#{attrs[:size]}\" from \"Creative Size\""
  When "I attach file \"#{attrs[:image]}\" to \"creatives_#{attrs[:number]}_image\" in selenium mode"
end

When /^I fill in "([^"]*)" information for the "([^"]*)" creative$/ do |name, number|
  default_overrides = { 
    :name => name, 
    :number => english_to_integer(number) 
  }

  populate_creative_form(default_overrides)
end

Then /^I should see the new creative form$/ do
  Then "I should see \"Creative Code\""
  Then "I should see \"Creative Name\""
  Then "I should see \"Media Type\""
  Then "I should see \"Creative Size\""
  Then "I should see \"Image\""
  Then "I should see \"Landing Page URL\""
end


Given /^I attach file "([^"]*)" to "([^"]*)" in selenium mode$/ do |file_name, field|
  path = File.join(RAILS_ROOT, "public", "images", file_name)
  fill_in(field, :with => path)
end

Then /^I should see the associated creatives for campaign "([^"]*)"$/ do |campaign_code|
  for creative in Campaign.find_by_campaign_code(campaign_code).creatives
    Then "I should see \"BCODE - bname\""
    Then "I should see \"CCODE - cname\""
  end
end

Given /^campaign "([^"]*)" is associated with ais "([^"]*)"$/ do |campaign_code, ais_code|
  campaign = Campaign.find_by_campaign_code(campaign_code)
  ais = AdInventorySource.find_by_ais_code(ais_code)
  cic = CampaignInventoryConfig.new({
    :ad_inventory_source_id => ais.id,
    :campaign_id => campaign.id
  })

  cic.save
end

Then /^I should see the configured ad inventory sources for "([^"]*)"$/ do |campaign_code|
  for ais in Campaign.find_by_campaign_code(campaign_code).aises do
    Then "I should see \"#{ais.name}\""
  end
end

Then /^I wait for page to load$/ do
  @seleniu.wait_for_condition "selenium.browserbot.getCurrentWindow().document.ready(function(){ return true;});"
end

Given /^the campaign "([^"]*)" is related to line item "([^"]*)"$/ do |campaign_code, line_item_code|
  @line_item = LineItem.find_by_line_item_code(line_item_code)
  Campaign.find_by_campaign_code(campaign_code).update_attributes({
    :line_item => LineItem.find_by_line_item_code(line_item_code)
  })
end

Given /^the campaign "([^"]*)" is related to audience "([^"]*)"$/ do |campaign_code, audience_code|
  Campaign.find_by_campaign_code(campaign_code).audience = 
    Audience.find_by_audience_code(audience_code)
end

Then /^the edit campaign form should be properly populated$/ do
  Then "I should see \"Ad-Hoc\""
  Then "I should see \"Ford Spring\" within \"select\#campaign_line_item\""
  Then "the \"Campaign Name\" field should contain \"Ford Campaign\""
  Then "I should see \"ACODE\""
  Then "the \"S3 Bucket\" field should contain \"bucket:/a/bucket\""
  Then "the \"Audience Name\" field should contain \"Ford Connected\""
  Then "I should see \"Inventory Sources\""
  Then "the \"ApN\" checkbox should be checked"
  Then "the \"AppNexus Segment Id\" field should contain \"123\""
end

Given /^campaign "([^"]*)" has segment id "([^"]*)" on ais "([^"]*)"$/ do |campaign_code, segment_id, ais_code|
  campaign = Campaign.find_by_campaign_code(campaign_code)
  ais = AdInventorySource.find_by_ais_code(ais_code)
  campaign.configure_ais(ais, segment_id)
end

Given /^Debug$/ do
  debugger
end
