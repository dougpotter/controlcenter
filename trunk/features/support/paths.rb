module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'
    when /the new ad_hoc_source page/
      new_ad_hoc_source_path

    when /the new creative page/
      new_creative_path

    when /the new creative_size page/
      new_creative_size_path

    when /the new audience page/
      new_audience_path

    when /the new line_item page/
      new_line_item_path

    when /the new manage_line_items page/
      new_manage_line_items_path

    when /the new manage_line_items page/
      new_manage_line_items_path

    when /the new ad_inventory_source page/
      new_ad_inventory_source_path

    when /the edit ad_inventory_source page for AdX/
      edit_ad_inventory_source_path(AdInventorySource.find_by_ais_code("AdX").id)

    when /the edit line item page for ABC12/
      edit_line_item_path(LineItem.find_by_line_item_code("ABC12").id)

    when /the edit creative page for ACODE/
      edit_creative_path(Creative.find_by_creative_code("ACODE").id)

    when /the edit campaign page for ACODE/
      edit_campaign_path(Campaign.find_by_campaign_code("ACODE").id)

    when /the show campaign page for ANB6/
      campaign_path(Campaign.find_by_campaign_code("ANB6").id)

    when /the show campaign page for ACODE/
      campaign_path(Campaign.find_by_campaign_code("ACODE").id)

    when /the edit partner page for 123432/
      edit_partner_path(Partner.find_by_partner_code("123432").id)

    when /the show line_item page for ABC1/
      line_item_path(LineItem.find_by_line_item_code("ABC1").id)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
