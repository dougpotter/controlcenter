Feature:
  In order to have a starting point of campaign managemnt
  ops
  will need a campaign dashboard

  Scenario:
    Given the standard ad-hoc campaign and associated entities exist
    When I am on the campaign dashboard page
    Then I should see "Actions"
    And I should see the action links
    And I should see "Active Campaigns"
    And I should see campaign ACODE's partner, Name, Code, and Fly Dates
