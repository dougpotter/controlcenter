Feature: Manage creatives
  In order to account for creatives used in past, current, and future campaigns
  an ad ops specialist
  wants to use XGCC for storing, viewing, associating, and removing creatives

  @appnexus
  Scenario: Create a new creative without a campaign
    Given the standard ais, partner, line item, audience, creative size setup exists
    And I am on the new creative page
    And I fill in the following:
      | Landing Page URL | http://www.xcdn.com/whatever |
    And I select "Ford" from "Partner"
    And I attach the image "for_testing/160x600_8F_Interim_final.gif" to "creative_image"
    When I press "Create Creative"
    Then I should see "creative successfully created"
    And I should see "New Creative"
    And Then I remove creatives from Appnexus sandbox

  @selenium @appnexus
  Scenario: create a new creative with a campaign
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the new creative page
    And I fill in the following:
      | Landing Page URL | http://www.xcdn.com/whatever |
    And I select "Ford" from "Partner"
    And I select "Ford Campaign" from "Campaign"
    And I attach the image "for_testing/160x600_8F_Interim_final.gif" to "creative_image"
    When I press "Create Creative"
    Then I should see "creative successfully created"
    And I should see "New Creative"
    And Then I remove creatives from Appnexus sandbox

  @selenium 
  Scenario: Remove a creative
    Given the standard ad-hoc campaign and associated entities exist
    And the following creatives are associated with campaign "ACODE":
      | creative_code |  name  | media_type | creative_size_common_name |   landing_page_url  |   file name |
      |     ACODE     |  aname |   flash    |         Medium            | http://www.what.com |  160x600_8F_Interim_final.gif |
    And I am on the edit creative page for ACODE
    When I press "Delete Creative"
    Then I should see a "Are you sure you want to delete this creative?" JS dialog
    And I should see "creative deleted"
    And I should not see "aname"

  Scenario: Show creative
    Given the standard ad-hoc campaign and associated entities exist
    And the following creatives are associated with campaign "ACODE":
      | creative_code |  name  | media_type | creative_size_common_name |   landing_page_url  |   file name |
      |     ACODE     |  aname |   flash    |         Medium            | http://www.what.com |  160x600_8F_Interim_final.gif |
    And I am on the new creative page
    When I follow "ACODE"
    Then I should see "Creative Name: aname"
    And I should see "Creative Code: ACODE"
    And I should see "Media Type: flash"
    And I should see "Size: 250 x 300"
    And I should see "Campaigns: ACODE - Ford Campaign"

  @appnexus
  Scenario: update creative
    Given the standard ad-hoc campaign and associated entities exist
    And the following creatives are associated with campaign "ACODE":
      | creative_code |  name  | media_type | creative_size_common_name |   landing_page_url  |   file name |
      |     ACODE     |  aname |   flash    |         Medium            | http://www.what.com |  160x600_8F_Interim_final.gif |
    And I am on the edit creative page for ACODE
    And I fill in "Landing Page URL" with "http://google.com"
    When I press "Save Edits"
    Then I should see "creative successfully updated"
    And I should see "New Creative"

  @selenium 
  Scenario: Filter campaigns by choosing a partner
    Given the standard ad-hoc campaign and associated entities exist
    And the secondary ad-hoc campaign and associated entities exist
    And I am on the new creative page
    When I select "Ford" from "Partner"
    Then I should see "Ford Campaign"
    And I should not see "Shamwow Campaign"
