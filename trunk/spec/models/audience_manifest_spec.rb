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

  it "should fail to create new instance with missing audience id (validation)" do
    a = Factory.build(:audience_manifest, :audience_id => nil)
    a.should have(1).error_on(:audience_id)
  end

  it "should fail to create new instance with missing audience id (db)" do
    lambda {
      a = Factory.build(:audience_manifest, :audience_id => nil)
      a.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should fail to create new instance with missing audience source id (validation)" do
    a = Factory.build(:audience_manifest, :audience_source_id => nil)
    a.should have(1).error_on(:audience_source_id)
  end

  it "should fail to create new instance with missing audience source id (db)" do
    lambda {
      a = Factory.build(:audience_manifest, :audience_source_id => nil)
      a.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should fail to create a new instance with invalid audience id (db)" do
    lambda {
      Factory.create(:audience_manifest, :audience_id => 9999)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should fail to create a new instance with invalid audience source id (db)" do
    lambda {
      Factory.create(:audience_manifest, :audience_id => 9999)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should populate the audience iteration number with 0 on first audience iteration" do
    audience = Factory.build(:audience)
    audience_source = Factory.build(:audience_source)

    am = Factory.build(
      :audience_manifest, 
      :audience_id => audience.id, 
      :audience_source_id => audience_source.id
    )

    am.save
    am.audience_iteration_number.should == 0
  end

  it "should populate the audience iteration number with 1 on second audience iteration" do
    audience = Factory.create(:audience)
    audience_source1 = Factory.create(:audience_source)

    am1 = Factory.build(
      :audience_manifest, 
      :audience_id => audience.id, 
      :audience_source_id => audience_source1.id
    )
    am1.save

    audience_source2 = Factory.create(:audience_source)
    am2 = Factory.build(
      :audience_manifest,
      :audience_id => audience.id,
      :audience_source_id => audience_source2.id
    )
    am2.save

    am2.audience_iteration_number.should == 1
  end
end
