Given /^the following creatives:$/ do |creatives|
  for hash in creatives.hashes
    creative = Creative.new(hash)
    creative.save
  end
end

Given /^the following creatives are associated with campaign "([^"]*)":$/ do |campaign_code, creatives|
  campaign = Campaign.find_by_campaign_code(campaign_code)
  line_item = campaign.line_item
  if line_item && campaign
    for hash in creatives.hashes
      hash["creative_size_id"] = CreativeSize.find_by_common_name(
        hash.delete("creative_size_common_name")
      ).id
      creative = Creative.new(hash)
      creative.campaigns << campaign
      creative.line_items << line_item
      creative.save
    end
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) creative$/ do |pos|
  visit creatives_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following creatives:$/ do |expected_creatives_table|
  expected_creatives_table.diff!(tableish('table tr', 'td,th'))
end

Given /^I attach the image "([^"]*)" to "([^"]*)"$/ do |name, field|
  local_path_to_creative = File.join(RAILS_ROOT, "public", "images", name)
  fill_in(field, :with => local_path_to_creative)
  FileUtils.rm_rf(File.join(RAILS_ROOT, "test-creatives"))
end

Then /^I should see a "([^"]*)" JS dialog$/ do |message|
  selenium.confirmation.should eql(message)
end

Given /^creative "([^"]*)" is associated with campaign "([^"]*)"$/ do |creative_code, campaign_code|
  @creative = Creative.find_by_creative_code(creative_code)
  @creative.campaigns << Campaign.find_by_campaign_code(campaign_code)
  @creative.save
end
