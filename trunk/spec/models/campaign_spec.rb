require 'spec_helper'

describe Campaign do
  before(:each) do
    @valid_attributes = {
      :description => "monster campaign",
      :campaign_code => "XG8100",
      :start_date => Date.today,
      :end_date => Date.today + 1,
      :partner_id => 1,
      :cid => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Campaign.create!(@valid_attributes)
  end

  it "should require non nill description" do
    lambda {
      Campaign.create!(@valid_attributes.merge({:description => nil}))
    }.should raise_error
  end

  it "should require a date start_date" do
    lambda {
      Campaign.create!(@valid_attributes.merge({:start_date => "not a date"}))
    }.should raise_error
  end

  it "should require a date end_date" do
    lambda {
      Campaign.create!(@valid_attributes.merge({:end_date => "not a date"}))
    }.should raise_error
  end

  it "should require end date to be >= start date" do
    lambda {
      Campaign.create!(@valid_attributes.merge({:end_date => (Date.today - 1)}))
    }.should raise_error
  end

  it "should require integer partner_id" do
    lambda {
      Campaign.create!(@valid_attributes.merge({:partner_id => "not and int"}))
    }.should raise_error
  end

  it "should require integer cid" do
    lambda {
      Campaign.create!(@valid_attributes.merge({:cid => "not and int"}))
    }.should raise_error 
  end

  it "shoud require unique cid" do
    Campaign.create!(@valid_attributes)
    lambda {
      Campaign.create!(@valid_attributes)
    }.should raise_error
  end
end
