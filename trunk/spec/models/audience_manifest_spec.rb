require 'spec_helper'

describe AudienceManifest do
  it "should create new instance given valid attributes" do
    Factory.create(:audience_manifest)
  end

  it "should not allow duplicate audience id - audience source id combinations" do
    a1 = Factory.build(:audience_manifest)
    audience_id = a1.audience_id
    audience_source_id = a1.audience_source_id
    a1.save
    a2 = Factory.build(
      :audience_manifest, 
      :audience_id => audience_id, 
      :audience_source_id => audience_source_id
    )
    lambda {
      a2.save
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should faild to create new instance with missing audience id (validation)" do
    lambda {
      Factory.create(:audience_manifest, :audience_id => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should faild to create new instance with missing audience id (db)" do
    lambda {
      a = Factory.build(:audience_manifest, :audience_id => nil)
      a.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should faild to create new instance with missing audience source id (validation)" do
    lambda {
      Factory.create(:audience_manifest, :audience_source_id => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should faild to create new instance with missing audience source id (db)" do
    lambda {
      a = Factory.build(:audience_manifest, :audience_source_id => nil)
      a.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end
end
