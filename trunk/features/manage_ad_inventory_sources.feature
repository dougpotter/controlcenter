Feature: Manage AISes

  In order to track relationships with sources of ad inventory
  As and ad ops specialist
  I will need to manage AISes in XGCC

  Scenario: See list of existing AISes
    Given the following ad inventory sources:
      |         name         | ais_code |
      |        Google        |   AdX    |
      |  Burst Ad Conductor  |   AdC    |
    When I am on the new ad inventory source page
    Then I should see "Google"
    And I should see "AdX"
    And I should see "Burst Ad Conductor"
    And I should see "AdC"

  Scenario: Create new AIS
    Given I am on the new ad inventory source page
    And I fill in the following:
      | AIS Code |      TSQUA      |
      |   Name   |   Time Square   |
    When I press "Create AIS"
    Then I should see "AIS successfully saved"
    And I should see "TSQUA"
    And I should see "Time Square"


