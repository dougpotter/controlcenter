Feature:
  In order to edit a piece of work for an advertiser
  an ad ops specialist
  will want to be able to update relevant attributes of a campaign

  Scenario: for a fully associated ad-hoc campaign, edit form should correclty populate 
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

  @selenium
  Scenario: for an ad-hoc campaign missing an audience, associating a new audience in edit UI
    Given the standard ad-hoc campaign and associated entities exist
    And I am on the edit campaign page for ACODE
    And I select "Ad-Hoc" from "Audience Type"
    And I fill in the following:
      | S3 Bucket     | bucket:/a/path/in/s3/ |
      | Audience Code | AUDCO                 |
      | Audience Name | Ford Connected T1     |
    When I press "Save Edits"
    Then I should see "ACODE - Ford Campaign"
    And I should see "Audience: AUDCO - Ford Connected T1"
    And I should be on the show campaign page for ACODE

  @selenium
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

  @selenium
  Scenario: on a fully associated ad-hoc campaign, change the audience source with the edit campaign UI
    Given the standard ad-hoc campaign and associated entities exist
    And the audience "HNXT" is associated with ad-hoc source "bucket:/a/bucket"
    And campaign "ACODE" is associated with audience "HNXT"
    And I am on the edit campaign page for ACODE
    And I fill in the following:
      | S3 Bucket     | bucket:/a/nwe/bucket |
    When I press "Save Edits"
    Then I should see "ACODE - Ford Campaign"
    And I should see "HNXT - Ford Connected"
    And I should be on the show campaign page for ACODE

  @selenium 
  Scenario: on a fully associated ad-hoc campaign, change the audience name with the edit campaign UI
    Given the standard ad-hoc campaign and associated entities exist
    And the audience "HNXT" is associated with ad-hoc source "bucket:/a/bucket"
    And campaign "ACODE" is associated with audience "HNXT"
    And I am on the edit campaign page for ACODE
    And I fill in the following:
      | Audience Name | A New Name |
    When I press "Save Edits"
    Then I should see "ACODE - Ford Campaign"
    And I should see "HNXT - A New Name"
    And I should be on the show campaign page for ACODE
