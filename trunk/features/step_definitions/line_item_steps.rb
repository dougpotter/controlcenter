Given /^the following line_items:$/ do |line_items|
  LineItem.create!(line_items.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) line_item$/ do |pos|
  visit line_items_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following line_items:$/ do |expected_line_items_table|
  expected_line_items_table.diff!(tableish('table tr', 'td,th'))
end
