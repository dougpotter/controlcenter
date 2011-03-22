Feature: Manage campaigns
  In order to manage pieces of work for advertisers
  and ad ops specialist 
  will want to remove and view campaigns

  #delete
  @selenium 
  Scenario: delete campaign
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the edit campaign page for ACODE
    When I press "Delete Campaign"
    Then I should see a "Are you sure you want to delete this campaign? All creative associations (but not the actual creatives), ais associations (but not the ais), and audience associations (but not the audience) will also be deleted." JS dialog
    And I should not see "Ford Campaign"
    And I should not see "ACODE"
    And I should see "campaign deleted"

  #show
  Scenario: show campaign
    Given the standard ad-hoc campaign and associated entities exist
    And the following creatives are associated with campaign "ACODE":
      | creative_code |  name  | media_type | creative_size_common_name |   landing_page_url  |
      |     BCODE     |  bname |   flash    |         Medium            | http://www.what.com |
      |     CCODE     |  cname |   flash    |         Medium            | http://www.what.com |
    And campaign "ACODE" is associated with audience "HNXT"
    And campaign "ACODE" is associated with ais "AdX"
    When I am on the show campaign page for ACODE
    Then I should see "ACODE - Ford Campaign"

    And I should see "Campaign Information"
    And I should see "Line Item: Ford Spring"
    And I should see "Audience Type: Ad-Hoc"
    And I should see "Audience: HNXT - Ford Connected"
    And I should see "Campaign Name: Ford Campaign"
    And I should see "Campaign Code: ACODE"

    And I should see "Creatives"
    And I should see the associated creatives for campaign "ACODE"

    And I should see "Configured Ad Inventory Sources"
    And I should see the configured ad inventory sources for "ACODE"

    And I should see "Edit Campaign"
