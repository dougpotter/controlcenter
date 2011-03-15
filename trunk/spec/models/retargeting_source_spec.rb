require 'spec_helper'

describe RetargetingSource do

  it "should create a new instance given valid attributes" do
    Factory.create(:retargeting_source)
  end

  it "should fail to create new instance given an s3 bucket" do
    lambda {
      Factory.create(:retargeting_source, :s3_bucket => "bucket:/a/bucket")
    }.should raise_error
  end

  it "should fail to create new instance given a load status" do
    lambda {
      Factory.create(:retargeting_source, :load_staus => "pending")
    }.should raise_error
  end

  it "should fail to create a new instance given a beacon load id" do
    lambda {
      Factory.create(:retargeting_source, :beacon_retargeting_id => "ABC123")
    }.should raise_error
  end

  it "should fail to create new instance given only request regex" do
    lambda {
      Factory.create(:retargeting_source, :referrer_regex => nil)
    }.should raise_error
  end

  it "should fail to create new instance given only referrer regex" do
    lambda {
      Factory.create(:retargeting_source, :request_regex => nil)
    }.should raise_error
  end
end
