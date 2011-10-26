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

  context "\#same_as" do
    it "should return true if self points to same location as source passed" do
      source1 = Factory.create(:ad_hoc_source, :s3_bucket => "samebucket:/a/path")
      source2 = Factory.create(:ad_hoc_source, :s3_bucket => "samebucket:/a/path")
      source1.same_as(source2).should be_true
    end

    it "should return false if self points to same location as source passed" do
      source1 = Factory.create(:ad_hoc_source, :s3_bucket => "samebucket:/a/path")
      source2 = Factory.create(:ad_hoc_source, :s3_bucket => "different:/a/path")
      source1.same_as(source2).should be_false
    end
  end
end
