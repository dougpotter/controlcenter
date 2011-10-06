When /^I request a new appnexus agent$/ do
  @agent = AppnexusClient::API.new_agent
end

Then /^the appnexus agent should be authenticated$/ do
  @agent.headers["Authorization"].should_not == nil
end
