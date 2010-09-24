require 'spec_helper'

describe UniqueImpressionCount do
  it "should create a new instance given valid attributes" do
    Factory.create(:unique_impression_count)
  end

  it "should require non-null unique_impression_count (validations test)" do
    lambda {
      Factory.create(:unique_impression_count, {:unique_impression_count => nil})
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require non-null unique_impression_count (db test)" do
    f = Factory.build(:unique_impression_count, {:unique_impression_count => nil})
    lambda {
      f.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require start time before end time" do 
    lambda {
      Factory.create(:unique_impression_count, { :start_time => Time.now + 60.minutes, :end_time => Time.now})
    }.should raise_error
  end

  it "should require numerical unique_impression_count" do
    lambda {
      Factory.create(:unique_impression_count, {:unique_impression_count => "string"})
    }.should raise_error
  end

  it "should require valid foreign key to partners" do
    lambda {
      Factory.create(:unique_impression_count, {:partner_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to campaigns" do
    lambda {
      Factory.create(:unique_impression_count, {:campaign_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to media purchase methods" do
    lambda {
      Factory.create(:unique_impression_count, {:media_purchase_method_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to audiences" do
    lambda {
      Factory.create(:unique_impression_count, {:audience_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to creatives" do
    lambda {
      Factory.create(:unique_impression_count, {:creative_id => 0})
    }.should raise_error
  end
end
