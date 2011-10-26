Given /^the following ad_hoc_sources:$/ do |ad_hoc_sources|
  AdHocSource.create!(ad_hoc_sources.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) ad_hoc_source$/ do |pos|
  visit ad_hoc_sources_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following ad_hoc_sources:$/ do |expected_ad_hoc_sources_table|
  expected_ad_hoc_sources_table.diff!(tableish('table tr', 'td,th'))
end
