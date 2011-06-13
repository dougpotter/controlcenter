Feature: Manage partners
  In order to provide a reposity of advertising partners
  an ad ops specialist
  wants to manage advertising parterns in XGCC
  
  Scenario: Create new partner
    Given I am on the new partner page
    And I fill in the following:
      | Advertiser Name | Coca Cola |
    When I press "Create Advertiser"
    Then I should see "Coca Cola"
    And I should see "Coca Cola successfully created"

  Scenario: Edit partner
    Given the following partners:
      |   name    | partner_code |
      | Coca Cola |    123432    |
    And I am on the new partner page
    When I follow "Coca Cola"
    Then I should see "Edit Advertiser"
    And the "Advertiser Code" field should contain "123432"
    And the "Advertiser Name" field should contain "Coca Cola"

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
