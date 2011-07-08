Feature: Manage campaigns
  In order to manage pieces of work for advertisers
  and ad ops specialist 
  will want to remove and view campaigns

  @selenium 
  Scenario: delete campaign
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the edit campaign page for ACODE
    When I press "Delete Campaign"
    Then I should see a "Are you sure you want to delete this campaign? All creative associations (but not the actual creatives), ais associations (but not the ais), and audience associations (but not the audience) will also be deleted." JS dialog
    And I should not see "Ford Campaign"
    And I should not see "ACODE"
    And I should see "campaign deleted"

  Scenario: show campaign
    Given the standard ad-hoc campaign and associated entities exist
    And the following creatives are associated with campaign "ACODE":
      | creative_code |  name  | media_type | creative_size_common_name |   landing_page_url  |   file name |
      |     BCODE     |  bname |   flash    |         Medium            | http://www.what.com |  160x600_8F_Interim_final.gif |
      |     CCODE     |  cname |   flash    |         Medium            | http://www.what.com |  160x600_8F_Interim_final.gif |
    And the audience "HNXT" is associated with ad-hoc source "bucket:/a/bucket"
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


  Scenario: edit campaign form
    Given the standard ad-hoc campaign and associated entities exist
    When I am on the edit campaign page for ACODE
    Then the edit campaign form should be properly populated

  @selenium @wip
  Scenario: refresh audience
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the edit campaign page for ACODE
    And I check "Refresh"
    And I fill in "bucket:/a/new/bucket" for "New S3 Bucket"
    When I press "Save Edits"
    Then I should see "campaign successfully updated"
    And I should see "Version: 1"

  Scenario: change segment id 
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the edit campaign page for ACODE
    And I fill in "88888" for "AppNexus Segment Id"
    When I press "Save Edits"
    And I am on the edit campaign page for ACODE
    Then the "AppNexus Segment Id" field should contain "88888"

  Scenario: disassociate segment id via edit page
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the edit campaign page for ACODE
    And I uncheck "ApN"
    When I press "Save Edits"
    Then I should not see "123"

  Scenario: create new campaign
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the new campaign page
    And I select "Ford Spring" from "Line Item"
    And I select "Ad-Hoc" from "Audience Type"
    And I fill in "Second Campaign" for "Campaign Name"
    And I fill in "bucket:/a/bucket" for "S3 Bucket"
    And I fill in "AUDCOD" for "Audience Code"
    And I fill in "Audience Name" for "Audience Name"
    And I check "ApN"
    And I fill in "54321" for "AppNexus Segment Id"
    When I press "submit"
    Then I should see "campaign successfully created"
    And I should see "AppNexus - 54321"
