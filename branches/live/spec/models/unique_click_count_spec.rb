# == Schema Information
# Schema version: 20101220202022
#
# Table name: unique_click_counts
#
#  id                       :integer(4)      not null, primary key
#  partner_id               :integer(4)
#  campaign_id              :integer(4)
#  media_purchase_method_id :integer(4)
#  audience_id              :integer(4)
#  creative_id              :integer(4)
#  start_time               :datetime        not null
#  end_time                 :datetime        not null
#  duration_in_minutes      :integer(4)      not null
#  unique_click_count       :integer(4)      not null
#

require 'spec_helper'

describe UniqueClickCount do
  it "should create a new instance given valid attributes" do
    Factory.create(:unique_click_count)
  end

  it "should require non-null unique_click_count (validations test)" do
    lambda {
      Factory.create(:unique_click_count, {:unique_click_count => nil})
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require non-null unique_click_count (db test)" do
    f = Factory.build(:unique_click_count, {:unique_click_count => nil})
    lambda {
      f.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require start time before end time" do 
    lambda {
      Factory.create(:unique_click_count, { :start_time => Time.now + 60.minutes, :end_time => Time.now})
    }.should raise_error
  end

  it "should require numerical unique_click_count" do
    lambda {
      Factory.create(:unique_click_count, {:unique_click_count => "string"})
    }.should raise_error
  end

  it "should require valid foreign key to partners" do
    lambda {
      Factory.create(:unique_click_count, {:partner_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to campaigns" do
    lambda {
      Factory.create(:unique_click_count, {:campaign_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to media purchase methods" do
    lambda {
      Factory.create(:unique_click_count, {:media_purchase_method_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to audiences" do
    lambda {
      Factory.create(:unique_click_count, {:audience_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to creatives" do
    lambda {
      Factory.create(:unique_click_count, {:creative_id => 0})
    }.should raise_error
  end
end
