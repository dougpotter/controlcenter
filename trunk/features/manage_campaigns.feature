Feature: Manage campaigns
  In order to manage pieces of work for advertisers
  and ad ops specialist 
  wants to create, edit, remove and view campaigns

  Scenario: Create a new Ad-Hoc campaign with no creatives and no AIS
    Given the standard ais, partner, line item, audience, creative size setup exists
    And I am on the new campaign page
    And I fill in ad-hoc campaign information
    When I press "submit"
    Then I should see "campaign successfully created"
    And I should see "ANB6"
    And I should see "A New Campaign for Ford"

  @selenium 
  Scenario: Click new creative
    Given the following ad_inventory_sources:
      |  ais_code |       name         |
      |    ApN    |      AppNexus      |
    And I am on the new campaign page
    When I follow "add_creative"
    Then I should see the new creative form

  @selenium
  Scenario: Create a new Ad-Hoc campaign with one creative and no AIS
    Given the standard ais, partner, line item, audience, creative size setup exists
    And I am on the new campaign page
    And I fill in ad-hoc campaign information
    And I follow "add_creative"
    And I fill in "fall skyscraper" information for the "first" creative
    When I press "submit"
    Then I should see "campaign successfully created"
    And I should see "ANB6"
    And I should see "A New Campaign for Ford"

  @selenium
  Scenario: Create a new Ad-Hoc campaign with two creatives and no AIS
    Given the standard ais, partner, line item, audience, creative size setup exists
    And I am on the new campaign page
    And I fill in ad-hoc campaign information
    And I follow "add_creative"
    And I fill in "fall skyscraper" information for the "first" creative
    And I follow "add_creative"
    And I fill in "fall medium" information for the "second" creative
    When I press "submit"
    Then I should see "campaign successfully created"
    And I should see "ANB6"
    And I should see "A New Campaign for Ford"

  @selenium
  Scenario: Create a new Ad-Hoc campaign with one creative and no AIS after removing one creative during the setup process
    Given the standard ais, partner, line item, audience, creative size setup exists
    And I am on the new campaign page
    And I fill in ad-hoc campaign information
    And I follow "add_creative"
    And I fill in "fall skyscraper" information for the "first" creative
    And I follow "add_creative"
    And I fill in "fall medium" information for the "second" creative
    And I follow "remove_creative"
    When I press "submit"
    Then I should see "campaign successfully created"
    And I should see "ANB6"
    And I should see "A New Campaign for Ford"