Feature: Manage creative_sizes
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
