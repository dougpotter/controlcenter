Feature: Manage AISes

  In order to track relationships with sources of ad inventory
  As and ad ops specialist
  I will need to manage AISes in XGCC

  Scenario: See list of existing AISes
    Given the following ad_inventory_sources:
      |         name         | ais_code |
      |        Google        |   AdX    |
      |  Burst Ad Conductor  |   AdC    |
    When I am on the new ad inventory source page
    Then I should see "Google"
    And I should see "AdX"
    And I should see "Burst Ad Conductor"
    And I should see "AdC"

  Scenario: Create new AIS
    Given I am on the new ad_inventory_source page
    And I fill in the following:
      | AIS Code |      TSQUA      |
      |   Name   |   Time Square   |
    When I press "Create AIS"
    Then I should see "AIS successfully saved"
    And I should see "TSQUA"
    And I should see "Time Square"

  Scenario: Edit AIS
    Given the following ad_inventory_sources:
      |         name         | ais_code |
      |        Google        |   AdX    |
      |  Burst Ad Conductor  |   AdC    |
    And I am on the new ad inventory source page
    When I follow "Google"
    Then I should see "Edit Ad Inventory Source"
    And the "AIS Code" field should contain "AdX"
    And the "Name" field should contain "Google"

  Scenario: Update AIS
    Given the following ad_inventory_sources:
      |         name          | ais_code |
      |   Google Ad Exchange  |   AdX    |
      |   Burst Ad Conductor  |   AdC    |
    And I am on the edit ad inventory source page for AdX
    And I fill in the following:
      |   Name   | Google |
    When I press "Save Edits"
    Then I should see "Google successfully updated"
    And I should not see "Google Ad Exchange"
