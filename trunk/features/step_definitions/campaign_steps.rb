Given /^the following campaigns:$/ do |campaigns|
  Campaign.create!(campaigns.hashes)
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
  field = "sync_checkbox_for_#{ais}"
  check(field)
end
