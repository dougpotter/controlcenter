Given /^the following audiences:$/ do |audiences|
  Audience.create!(audiences.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) audience$/ do |pos|
  visit audiences_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following audiences:$/ do |expected_audiences_table|
  expected_audiences_table.diff!(tableish('table tr', 'td,th'))
end

Given /^the standard partner, line item, and campaign exist$/ do
  When "the following partners:", table(%{
    | partner_code | name |
    |     11111    | Ford |
  })
  When "the following line_items:", table(%{
    | line_item_code |    name     | partner_code |
    |     ABC1       | Ford Spring |    11111     |   
  })
  When "the following campaigns:", table(%{
   | campaign_code | line_item_code |     name      |
   |     ACODE     |     ABC1       | Ford Campaign |
  })
end

Given /^the audience "([^"]*)" is associated with ad-hoc source "([^"]*)"$/ do |audience_code, ad_hoc_source_s3_bucket|
  audience = Audience.find_by_audience_code(audience_code)
  source = AdHocSource.find_by_s3_bucket(ad_hoc_source_s3_bucket)
  audience.update_source(source)
end
