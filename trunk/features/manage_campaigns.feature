Feature: Manage campaigns
  In order to manage pieces of work for advertisers
  and ad ops specialist 
  wants to create, edit, remove and view campaigns

  Scenario: Create a new Ad-Hoc campaign with no creatives and no AIS
    Given the standard ais, partner, line item, audience, creative size setup exists
    And I am on the new campaign page
    And I fill in ad-hoc campaign information
    When I press "submit"
    Then I should be on "the show campaign page for ANB6"
    And I should see "campaign successfully created"
    And I should see "ANB6 - A New Campaign for Ford"
    And I should see "A New Campaign for Ford"
    And I should see "Audience Type: Ad-Hoc"
    And I should see "Audience: HNXT - Ford Connected"

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

  Scenario: for a fully associated campaign, edit form should correclty populate 
    Given the standard ad-hoc campaign and associated entities exist
    And the audience "HNXT" is associated with ad-hoc source "bucket:/a/bucket"
    And campaign "ACODE" is associated with audience "HNXT"
    When I am on the edit campaign page for ACODE
    Then I should see "Ford Spring" 
    And I should see "Ad-Hoc"
    And the "Campaign Name" field should contain "Ford Campaign"
    And the "Campaign Code" field should contain "ACODE"
    And the "S3 bucket" field should contain "bucket:/a/bucket"
    And I should see "HNXT"
    And the "Audience Name" field should contain "Ford Connected"

  Scenario: for an ad-hoc campaign missing an audience, associating a new audience in edit UI
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the edit campaign page for ACODE
    And I fill in the following:
      | S3 Bucket     | bucket:/a/path/in/s3/ |
      | Audience Code | AUDCO                 |
      | Audience Name | Ford Connected T1     |
    When I press "Save Edits"
    Then I should be on the show campaign page for ACODE
    And I should see "ACODE - Ford Campaign"
    And I should see "Audience: AUDCO - Ford Connected T1"

  Scenario: for an ad-hoc campaign missing an audience, associating a new audience in edit UI with a duplicate audience code
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the edit campaign page for ACODE
    And I fill in the following:
      | S3 Bucket     | bucket:/a/path/in/s3/ |
      | Audience Code | HNXT                  |
      | Audience Name | Ford Connected T1     |
    When I press "Save Edits"
    Then I should be on the edit campaign page for ACODE
    And I should see "Audience code HNXT already exists, please choose a new one"

  Scenario: on a fully associated ad-hoc campaign, change the audience source with the edit campaign UI
    Given the standard ad-hoc campaign and associated entities exist
    And the audience "HNXT" is associated with ad-hoc source "bucket:/a/bucket"
    And campaign "ACODE" is associated with audience "HNXT"
    And I am on the edit campaign page for ACODE
    And I fill in the following:
      | S3 Bucket     | bucket:/a/nwe/bucket |
    When I press "Save Edits"
    Then I should be on the show campaign page for ACODE
    And I should see "ACODE - Ford Campaign"
    And I should see "HNXT - Ford Connected"

  Scenario: on a fully associated ad-hoc campaign, change the audience name with the edit campaign UI
    Given the standard ad-hoc campaign and associated entities exist
    And the audience "HNXT" is associated with ad-hoc source "bucket:/a/bucket"
    And campaign "ACODE" is associated with audience "HNXT"
    And I am on the edit campaign page for ACODE
    And I fill in the following:
      | Audience Name | A New Name |
    When I press "Save Edits"
    Then I should be on the show campaign page for ACODE
    And I should see "ACODE - Ford Campaign"
    And I should see "HNXT - A New Name"

