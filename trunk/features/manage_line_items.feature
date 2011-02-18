Feature: Manage line_items
  In order to track client engagements
  an ad ops specialist
  wants to create line items as containers for all campaigns for an advertiser 
  over a given time period
  
  Scenario: Create new line_item
    Given I am on the new line_item page
    And the following partners:
      | name | partner_code |
      | Ford |     11111    |
    And I fill in the following:
      | Line Item Code | ABC12 |
      | Line Item Name | Ford Spring 2008 |
    And I select "February 1, 2010" as the "Start Time" date 
    And I select "April 1, 2010" as the "End Time" date
    And I select "partner one" from "Existing Advertiser"
    When I press "Create Line Item"
    Then I should see "line item successfully saved"
    And I should see "Ford Spring 2008"
    And I should see "ABC12"
