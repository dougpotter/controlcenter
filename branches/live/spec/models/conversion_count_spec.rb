# == Schema Information
# Schema version: 20101220202022
#
# Table name: conversion_counts
#
#  id                  :integer(4)      not null, primary key
#  campaign_id         :integer(4)      not null
#  start_time          :datetime        not null
#  end_time            :datetime        not null
#  duration_in_minutes :integer(4)      not null
#  conversion_count    :integer(4)      not null
#

require 'spec_helper'

describe ConversionCount do

  it "should create a new instance given valid attributes" do
    Factory.create :conversion_count
  end

  it "should require presence of campaign_id (db test)" do
    c = Factory.build(:conversion_count, :campaign_id => nil)
    lambda {
      c.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require presence of campaign_id (validations test)" do
    pending
    lambda {
      Factory.create(:conversion_count, :campaign_id => nil)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require converison count to be a number" do 
    lambda {
      Factory.create(:conversion_count, :conversion_count => "not a num")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require a valid foreign key for campaign_id" do 
    lambda {
      Factory.create(:conversion_count, :campaign_id => 0)
    }.should raise_error
  end

  it "should require a start time that occurs before end time" do
    lambda {
      Factory.create(:conversion_count, {:start_time => Time.now + 60, :end_time => Time.now})
    }.should raise_error
  end
end
