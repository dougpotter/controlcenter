require 'spec_helper'

describe AdHocSource do
  it "should create a new instance given valid attributes" do
    Factory.create(:ad_hoc_source)
  end

  it "should fail to create a new instance given referrer regex" do
    lambda {
      Factory.create(:ad_hoc_source, :referrer_regex => "www.google.com\.*")
    }.should raise_error
  end

  it "should fail to create a new instance given request regex" do
    lambda {
      Factory.create(:ad_hoc_source, :request_regex => "www.google.com\.*")
    }.should raise_error
  end

  it "should fail to create a new instance given no s3 bucket" do
    lambda {
      Factory.create(:ad_hoc_source, :s3_bucket => nil)
    }.should raise_error
  end

  it "should faild to create a new instance given no load status" do
    lambda {
      Factory.create(:ad_hoc_source, :load_status => nil)
    }.should raise_error
  end

  it "should faild to create a new instance given no beacon load id" do
    lambda {
      Factory.create(:ad_hoc_source, :beacon_load_id => nil)
    }.should raise_error
  end
end
