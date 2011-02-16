Feature: Manage partners
  In order to provide a reposity of advertising partners
  an ad ops specialist
  wants to manage advertising parterns in XGCC
  
  Scenario: Create new partner
    Given I am on the new partner page
    When I fill in the following:
      | Advertiser Code | 123432    |
      | Advertiser Name | Coca Cola |
    Then I should see "Coca Cola"
    And I should see "123432"

  Scenario: Edit partner
    Given the following partners:
      |   name    | partner_code |
      | Coca Cola |    123432    |
    And I am on the new partner page
    When I follow "Coca Cola"
    Then I should see "Edit Advertiser"
    And the "Advertiser Code" field should contain "123432"
    And the "Advertiser Name" field should contain "Coca Cola"
