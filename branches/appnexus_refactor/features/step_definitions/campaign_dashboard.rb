Then /^I should see the action links$/ do
  Then "I should see \"New Campaign\"" 
  Then "I should see \"New Partner\"" 
  Then "I should see \"New Line Item\"" 
  Then "I should see \"New Creative\"" 
  Then "I should see \"New AIS\"" 
end

Then /^I should see campaign ACODE's partner, Name, Code, and Fly Dates$/ do
  Then "I should see \"Ford\"" 
  Then "I should see \"Ford Campaign\"" 
  Then "I should see \"ACODE\"" 
  Then "I should see \"04-20-2000\"" 
  Then "I should see \"06-20-2000\"" 
end
