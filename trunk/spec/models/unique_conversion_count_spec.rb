require 'spec_helper'

describe UniqueConversionCount do
  it "should create a new instance given valid attributes" do
    Factory.create(:unique_conversion_count)
  end

  it "should require non null unique conversion count (db test)" do
    u = Factory.build(:unique_conversion_count, :unique_conversion_count => nil)
    lambda {
      u.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require non null unique conversion count (validations test)" do
    lambda {
      Factory.create(:unique_conversion_count, :unique_conversion_count => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require unique_conversion_count to be a number" do 
    lambda {
      Factory.create(:unique_conversion_count, :unique_conversion_count => "not a number")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require a valid foreign key to campaigns" do
    lambda {
      Factory.create(:unique_conversion_count, :campaign_id => 0)
    }.should raise_error
  end

  it "should require a start time that occurs before end time" do
    lambda {
      Factory.create(:unique_conversion_count, {:start_time => Time.now + 60, :end_time => Time.now})
    }.should raise_error
  end
end
