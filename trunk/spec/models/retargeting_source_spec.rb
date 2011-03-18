require 'spec_helper'

describe RetargetingSource do
  it "should create new instance given only referrer regex" do
    Factory.create(:retargeting_source, :request_regex => nil)
  end

  it "should create new instance given only referrer regex" do
    Factory.create(:retargeting_source, :request_regex => nil)
  end

  it "should fail to create new instance given an s3 bucket" do
    lambda {
      Factory.create(:retargeting_source, :s3_bucket => "bucket:/a/bucket")
    }.should raise_error
  end

  it "should fail to create new instance given a load status" do
    lambda {
      Factory.create(:retargeting_source, :load_status => "pending")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should fail to create a new instance given a beacon load id" do
    lambda {
      Factory.create(:retargeting_source, :beacon_load_id=> "ABC123")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should fail to create new instance given no request or referrer regex" do
    lambda {
      Factory.create(:retargeting_source, :request_regex => nil, :referrer_regex => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  context "\#same_as" do
    it "should return true if the referrer regexes match" do
      source1 = Factory.create(:retargeting_source, :referrer_regex => "match")
      source2 = Factory.create(:retargeting_source, :referrer_regex => "match")
      source1.same_as(source2).should be_true
    end

    it "should return true if the request regexes match" do
      source1 = Factory.create(
        :retargeting_source, 
        :request_regex => "match",
        :referrer_regex => nil
      )
      source2 = Factory.create(
        :retargeting_source, 
        :request_regex => "match",
        :referrer_regex => nil
      )
      source1.same_as(source2).should be_true
    end

    it "should return false if the referrer regexes do not match" do
      source1 = Factory.create(:retargeting_source, :referrer_regex => "match")
      source2 = Factory.create(:retargeting_source, :referrer_regex => "notmatch")
      source1.same_as(source2).should be_false
    end

    it "should return false if the request regexes do not match" do
      source1 = Factory.create(:retargeting_source, :request_regex => "match")
      source2 = Factory.create(:retargeting_source, :request_regex => "notmatch")
      source1.same_as(source2).should be_false
    end
  end
end
