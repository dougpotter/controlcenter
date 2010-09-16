require 'spec_helper'

describe UniqueRemotePlacementCount do

  it "should create a new instance given valid attributes" do
    Factory.create(:unique_remote_placement_count)
  end

  it "should require unique_remote_placement_count to be non null (db test)" do
    u = Factory.build(:unique_remote_placement_count, :unique_remote_placement_count => nil)
    lambda {
      u.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require unique_remote_placement_count to be non null (validations test)" do
    lambda {
      Factory.create(:unique_remote_placement_count, :unique_remote_placement_count => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require unique_remote_placement_count to be a number" do
    lambda {
      Factory.create(:unique_remote_placement_count, :unique_remote_placement_count => "not a number")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require a valid foreign key to audiences" do
    lambda {
      Factory.create(:unique_remote_placement_count, :audience_id => 0)
    }
  end

  it "should require a start time that occurs before end time" do
    lambda {
      Factory.create(:unique_remote_placement_count, {:start_time => Time.now + 60, :end_time => Time.now})
    }.should raise_error
  end
end
