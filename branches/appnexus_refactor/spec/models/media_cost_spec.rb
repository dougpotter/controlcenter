# == Schema Information
# Schema version: 20101220202022
#
# Table name: media_costs
#
#  id                       :integer(4)      not null, primary key
#  partner_id               :integer(4)      not null
#  campaign_id              :integer(4)      not null
#  media_purchase_method_id :integer(4)      not null
#  audience_id              :integer(4)      not null
#  creative_id              :integer(4)      not null
#  start_time               :datetime        not null
#  end_time                 :datetime        not null
#  duration_in_minutes      :integer(4)      not null
#  media_cost               :float           not null
#

require 'spec_helper'

describe MediaCost do
  it "should create a new instance given valid attributes" do
    pending
    Factory.create(:media_cost)
  end

  it "should require non-null media cost (validations test)" do
    lambda {
      Factory.create(:media_cost, {:media_cost => nil})
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require non-null media cost (db test)" do
    f = Factory.build(:media_cost, {:media_cost => nil})
    lambda {
      f.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require start time before end time" do 
    lambda {
      Factory.create(:media_cost, { :start_time => Time.now + 60.minutes, :end_time => Time.now})
    }.should raise_error
  end

  it "should require numerical media cost" do
    lambda {
      Factory.create(:media_cost, {:media_cost => "string"})
    }.should raise_error
  end

  it "should require valid foreign key to partners" do
    lambda {
      Factory.create(:media_cost, {:partner_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to campaigns" do
    lambda {
      Factory.create(:media_cost, {:campaign_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to media purchase methods" do
    lambda {
      Factory.create(:media_cost, {:media_purchase_method_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to audiences" do
    lambda {
      Factory.create(:media_cost, {:audience_id => 0})
    }.should raise_error
  end

  it "should require valid foreign key to creatives" do
    lambda {
      Factory.create(:media_cost, {:creative_id => 0})
    }.should raise_error
  end
end
