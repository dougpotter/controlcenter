Given /^the following creative sizes:$/ do |creative_sizes|
  CreativeSize.create!(creative_sizes.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) creative_size$/ do |pos|
  visit creative_sizes_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following creative_sizes:$/ do |expected_creative_sizes_table|
  expected_creative_sizes_table.diff!(tableish('table tr', 'td,th'))
end
