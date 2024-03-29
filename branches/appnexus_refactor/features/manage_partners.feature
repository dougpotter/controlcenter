Feature: Manage partners
  In order to provide a reposity of advertising partners
  an ad ops specialist
  wants to manage advertising parterns in XGCC

  @clean_partners_from_apn_sandbox
  Scenario: Create new partner
    Given I am on the new partner page
    And I fill in the following:
      | Advertiser Name | Coca Cola |
    When I press "Create Advertiser"
    Then I should see "Coca Cola"
    And I should see "Coca Cola successfully created"

  @selenium
  Scenario: Create new partner with action tag
    Given I am on the new partner page
    And I press the action tag plus sign
    And I fill in the following:
      | Advertiser Name |       Coca Cola         |
      |      Name       |       sitewide          |
      |      SID        |         12345           |
      |      URL        |   http://cocacola.com   |
    When I press "Create Advertiser"
    Then I should see "Coca Cola successfully created"

  @selenium 
  Scenario: Create new partner with invalid action tags (duplicate SIDs)
    Given I am on the new partner page
    And I press the action tag plus sign
    And I fill in the following:
      | Advertiser Name |       Coca Cola         |
      |      Name       |       sitewide          |
      |      SID        |         12345           |
      |      URL        |   http://cocacola.com   |
    And I press the action tag plus sign
    And I fill in the following:
      | Advertiser Name |       Coca Cola         |
      |      partner_action_tags_attributes_2_name |       conversion        |
      |      partner_action_tags_attributes_2_sid |         12345           |
      |      partner_action_tags_attributes_2_url | http://cocacola.com/ty  |
    When I press "Create Advertiser"
    Then I should see "Invalid action tag"

  Scenario: Edit partner (basic form population check)
    Given the following partners:
      |   name    | partner_code |
      | Coca Cola |    123432    |
    And "Coca Cola" has the following action tags:
      |   name    |  sid   |           url            |
      | sitewide  | 12345  |  http://coke.com/thanks  |
    When I am on the edit partner page for 123432
    Then I should see "Edit Advertiser"
    And the "Advertiser Code" field should contain "123432"
    And the "Advertiser Name" field should contain "Coca Cola"
    And the "Name" field should contain "sitewide"
    And the "SID" field should contain "12345"
    And the "URL" field should contain "http://coke.com/thanks"

  @selenium 
  Scenario: Edit partner (remove action tag)
    Given the following partners:
      |   name    | partner_code |
      | Coca Cola |    123432    |
    And "Coca Cola" has the following action tags:
      |   name    |  sid   |           url            |
      | sitewide  | 12345  |  http://coke.com/thanks  |
    And I am on the edit partner page for 123432
    When I press the first action tag minus sign
    And I press "Save Edits"
    Then I should see "sitewide tag removed"

  @selenium 
  Scenario: Remove partner 
    Given the following partners:
      |   name    | partner_code |
      | Coca Cola |    123432    |
    And I am on the edit partner page for 123432
    When I press "Delete Advertiser"
    Then I should see a "Are you sure you want to delete this advertiser?" JS dialog
    And I should see "advertiser deleted"
    And I should see "New Advertiser"
    And I should not see "123432"
    And I should not see "Coca Cola"
