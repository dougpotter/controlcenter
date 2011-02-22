Given /^the following line_items:$/ do |line_items|
  for line_item in line_items.hashes
    if !LineItem.find_by_line_item_code(line_item[:line_item_code])
      partner_id = Partner.find_by_partner_code(line_item[:partner_code]).id
      line_item.delete("partner_code")
      line_item["partner_id"] = partner_id
      LineItem.create!(line_item)
    end
  end
end

Then /^I should see the following line_items:$/ do |expected_line_items_table|
  expected_line_items_table.diff!(tableish('table tr', 'td,th'))
end

Then /^the "([^"]*)" date field should contain "([^"]*)"$/ do |label, value|
  date_field_id_trunk = "line_item_#{label.downcase.gsub(" ", "_")}"
  year_field_id = date_field_id_trunk + "_1i"
  month_field_id = date_field_id_trunk + "_2i"
  day_field_id = date_field_id_trunk + "_3i"

  date = Date.parse(value)

  field_with_id(year_field_id).value.should == date.year.to_s
  field_with_id(month_field_id).value.should == date.month.to_s
  field_with_id(day_field_id).value.should == date.day.to_s
end

Then /^the "([^"]*)" field should display "([^"]*)"$/ do |label, selected| 
  desired_element_selected = false
  field_labeled(label).options.each do |option|
    if option.element.text == selected && !option.element.attributes["selected"].nil?
      desired_element_selected = true
    end
  end
  desired_element_selected.should == true
end
