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
