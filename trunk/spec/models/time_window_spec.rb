# == Schema Information
# Schema version: 20100803143344
#
# Table name: time_windows
#
#  id           :integer(4)      not null, primary key
#  window_begin :datetime
#  window_end   :datetime
#

require 'spec_helper'

describe TimeWindow do
  it "should create a new instance given valid attributes" do
    Factory.create(:time_window)
  end

  it "should require a start date of type Time" do
    lambda {
      Factory.create(:time_window, :window_begin => "not a time")
    }.should raise_error
  end

  it "should require an end date of type Time" do
    lambda {
      Factory.create(:time_window, :window_end => "not a time")
    }.should raise_error
  end

  it "sould require end date be after start date" do
    Factory.build(:time_window, {:window_begin => Time.now + 100, :window_end => Time.now})
  end
end
