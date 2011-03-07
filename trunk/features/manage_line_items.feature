Feature: Manage line_items
  In order to track client engagements
  an ad ops specialist
  wants to create line items as containers for all campaigns for an advertiser 
  over a given time period

  Scenario: Create new line_item
    Given the following partners:
      | name | partner_code |
      | Ford |     11111    |
    And I am on the new line_item page
    And I fill in the following:
      | Line Item Code | ABC12 |
      | Line Item Name | Ford Spring 2008 |
    And I select "February 1, 2010" as the "Start Time" date 
    And I select "April 1, 2010" as the "End Time" date
    And I select "Ford" from "Existing Advertiser"
    When I press "Create Line Item"
    Then I should see "line item successfully saved"
    And I should see "Ford Spring 2008"
    And I should see "ABC12"

  Scenario: Edit line_item
    Given the following partners:
      | name | partner_code |
      | Ford |     11111    |
    And the following line_items:
      | name | line_item_code | start_time | end_time | partner_code |
      | Ford Spring 2008 | ABC12 | February 1, 2010 | April 1, 2010 | 11111 |
    And I am on the new line_item page
    When I follow "Ford Spring 2008" 
    Then I should see "Edit Line Item"
    And the "Line Item Code" field should contain "ABC12"
    And the "Line Item Name" field should contain "Ford Spring 2008"
    And the "Start Time" date field should contain "February 1, 2010"
    And the "End Time" date field should contain "April 1, 2010"
    And the "Existing Advertiser" field should display "Ford"

  Scenario: Update line_item
    Given the following partners:
      | name | partner_code |
      | Ford |     11111    |
    And the following line_items:
      | name | line_item_code | start_time | end_time | partner_code |
      | Ford Spring 2008 | ABC12 | February 1, 2010 | April 1, 2010 | 11111 |
    And I am on the edit line item page for ABC12
    And the "Line Item Code" field should contain "ABC12"
    And the "Line Item Name" field should contain "Ford Spring 2008"
    And the "Start Time" date field should contain "February 1, 2010"
    And the "End Time" date field should contain "April 1, 2010"
    And the "Existing Advertiser" field should display "Ford"
    And I fill in the following:
      | Line Item Code | ABC13 |
    When I press "Save Edits"
    Then I should see "line item successfully updated"
    And I should see "ABC13"
    And I should not see "ABC12"

  @selenium @wip
  Scenario: remove line item
    Given the following partners:
      | name | partner_code |
      | Ford |     11111    |
    And the following line_items:
      | name | line_item_code | start_time | end_time | partner_code |
      | Ford Spring 2008 | ABC12 | February 1, 2010 | April 1, 2010 | 11111 |
      | Ford Spring 2009 | ABC13 | February 1, 2011 | April 1, 2011 | 11111 |
    And I am on the edit line item page for ABC12
    When I press "Delete Line Item"
    Then I should see a "Are you sure you want to delete this line item? All associated campaigns, creatives, ad inventory configurations, etc will also be delete." JS dialog
    And I should see "ABC13"
    And I should not see "ABC12"

