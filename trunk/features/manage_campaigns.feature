Feature: Manage campaigns
  In order to manage pieces of work for advertisers
  and ad ops specialist 
  wants to create, edit, remove and view campaigns
  
  Scenario: Create a new Ad-Hoc campaign with no creatives and no AIS
    Given the following ad_inventory_sources:
      |  ais_code |       name         |
      |    AdX    | Google Ad Exchange |
      |    ApN    |      AppNexus      |
    And the following partners:
      | partner_code | name |
      |     11111    | Ford |
    And the following line_items:
      | line_item_code |    name     | partner_code |
      |     ABC1       | Ford Spring |    11111     |
    And the following audiences:
      | audience_code |   description  |
      |      HNXT     | Ford Connected |
    And I am on the new campaign page
    And I select "Ford Spring" from "Line Item"
    And I select "Ad-Hoc" from "Audience Type"
    And I fill in the following:
      | Name | A New Campaign for Ford |
      | Campaign Code | ANB6 |
      | S3 Location | /a/path/in/s3 |
      | Audience Code | CODA |
    When I press "submit"
    Then I should see "campaign successfully created"
    And I should see "ANB6"
    And I should see "A New Campaign for Ford"
