Feature:
  In order to enter the relevant business information for a piece of advertising
  work
  an ad ops specialist
  will want to be able to create a new campaign
  
  Scenario: Create a new Ad-Hoc campaign with no creatives and no AIS
    Given the standard ais, partner, line item, audience, creative size setup exists
    And I am on the new campaign page
    And I fill in ad-hoc campaign information
    And I fill in the following:
      | Audience Code | AUDCOD |
    When I press "submit"
    Then I should be on "the show campaign page for ANB6"
    And I should see "campaign successfully created"
    And I should see "ANB6 - A New Campaign for Ford"
    And I should see "A New Campaign for Ford"
    And I should see "Audience Type: Ad-Hoc"
    And I should see "Audience: AUDCOD - An Audience for Ford"

  Scenario: Create a new Ad-Hoc campaign with no creative, no AIS, and a duplicate audience code
    Given the standard ais, partner, line item, audience, creative size setup exists
    And I am on the new campaign page
    And I fill in ad-hoc campaign information
    When I press "submit"
    Then I should be on "the campaigns page"
    And I should see "Audience code has already been taken"

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
