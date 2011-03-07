Given /^the following creatives:$/ do |creatives|
  Creative.create!(creatives.hashes)
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
