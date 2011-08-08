Given /^the following partners:$/ do |partners|
  for partner in partners.hashes
    if !Partner.find_by_partner_code(partner[:partner_code])
      Partner.create!(partner)
    end
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) partner$/ do |pos|
  visit partners_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following partners:$/ do |expected_partners_table|
  expected_partners_table.diff!(tableish('table tr', 'td,th'))
end

Then /^I press the action tag plus sign$/ do 
  click_button "add_action_tag"
end

Given /^"([^"]*)" has the following action tags:$/ do |partner_name, action_tags|
  partner_id = Partner.find_by_name(partner_name).id
  for action_tag in action_tags.hashes
    ActionTag.create!(action_tag.merge(:partner_id => partner_id))
  end
end
