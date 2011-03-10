Feature: Manage creatives
  In order to account for creatives used in past, current, and future campaigns
  an ad ops specialist
  wants to use XGCC for storing, viewing, associating, and removing creatives

  Scenario: Create a new creative without a campaign
    Given the standard ais, partner, line item, audience, creative size setup exists
    And I am on the new creative page
    And I fill in the following:
      | Creative Code    | ACODE                        |   
      | Name             | fall whatever                |   
      | Media Type       | flash                        |   
      | Landing Page URL | http://www.xcdn.com/whatever |
    And I select "90 x 728" from "Creative Size"
    And I attach the image "logo.png" to "creative_image"
    When I press "Create Creative"
    Then I should see "creative successfully created"
    And I should see "New Creative"

  Scenario: create a new creative with a campaign
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the new creative page
    And I fill in the following:
      | Creative Code    | ACODE                        |   
      | Name             | fall whatever                |   
      | Media Type       | flash                        |   
      | Landing Page URL | http://www.xcdn.com/whatever |
    And I select "90 x 728" from "Creative Size"
    And I attach the image "logo.png" to "creative_image"
    And I select "ACODE - Ford Campaign" from "Campaign"
    When I press "Create Creative"
    Then I should see "creative successfully created"
    And I should see "New Creative"

  @selenium 
  Scenario: Remove a creative
    Given the standard ad-hoc campaign and associated entities exist
    And the following creatives:
      | creative_code |  name  | media_type | creative_size_common_name |   landing_page_url  |  campaign_code |
      |     ACODE     |  aname |   flash    |    Medium     | http://www.what.com |      ACODE |
      |     BCODE     |  bname |   flash    |    Medium     | http://www.what.com |      ACODE |
    And I am on the edit creative page for ACODE
    When I press "Delete Creative"
    Then I should see a "Are you sure you want to delete this creative?" JS dialog
    And I should see "creative deleted"
    And I should not see "aname"

  Scenario: Show creative
    Given the standard ad-hoc campaign and associated entities exist
    And the following creatives:
      | creative_code |  name  | media_type | creative_size_common_name |   landing_page_url  |  campaign_code |
      |     ACODE     |  aname |   flash    |    Medium     | http://www.what.com |      ACODE |
      |     BCODE     |  bname |   flash    |    Medium     | http://www.what.com |      ACODE |
    And creative "ACODE" is associated with campaign "ACODE"
    And I am on the new creative page
    When I follow "ACODE"
    Then I should see "Creative Name: aname"
    And I should see "Creative Code: ACODE"
    And I should see "Media Type: flash"
    And I should see "Size: 250 x 300"
    And I should see "Campaigns: ACODE - Ford Campaign"
