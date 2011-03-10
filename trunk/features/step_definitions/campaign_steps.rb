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
    |     11111    | Ford |
  })
  When "the following line_items:", table(%{
    | line_item_code |    name     | partner_code |
    |     ABC1       | Ford Spring |    11111     |   
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
end

Given /^I fill in ad-hoc campaign information$/ do
  When "I select \"Ford Spring\" from \"Line Item\""
  When "I select \"Ad-Hoc\" from \"Audience Type\""
  And "I fill in the following:", table(%{
    | Campaign Name | A New Campaign for Ford |
    | Campaign Code | ANB6 |
    | S3 Location | bucket:/a/path/in/s3 |
    | Audience Code | CODA |
  })
end

Given /^the standard ad-hoc campaign and associated entities exist$/ do
  When "the standard ais, partner, line item, audience, creative size setup exists"
  Given "the following campaigns:", table(%{
    |      name      | campaign_code | line_item_code | 
    |  Ford Campaign |     ACODE     |     ABC1       |
  })
end

Given /^campaign "([^"]*)" is associated with audience "([^"]*)"$/ do |campaign_code, audience_code|
  @campaign = Campaign.find_by_campaign_code(campaign_code)
  @campaign.audience = Audience.find_by_audience_code(audience_code)
  @campaign.save
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

