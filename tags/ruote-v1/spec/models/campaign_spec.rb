require 'spec_helper'

describe Campaign do
  before(:each) do
    @partner_attr = {
      :name => "name"
    }
    @partner = Partner.create!(@partner_attr)
    @valid_attributes = {
      :description => "monster campaign",
      :campaign_code => "XG8100",
      :start_date => Date.today,
      :end_date => Date.today + 1,
      :partner_id => @partner.id,
      :cid => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Campaign.create!(@valid_attributes)
  end

  it "should require a parent partner" do
    lambda {
      Campaign.create!(@valid_attributes.merge(:partner_id => @partner.id + 1))
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require non nill description (validations test)" do
    lambda {
      Campaign.create!(@valid_attributes.merge({:description => nil}))
    }.should raise_error
  end

  it "should require non nill description (db test)" do
    lambda {
      c = Campaign.new(@valid_attributes.merge({:description => nil}))
      c.save_with_validation(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require non nill campaign code (validations test)" do
    lambda {
      Campaign.create!(@valid_attributes.merge({:campaign_code => nil}))
    }.should raise_error
  end

  it "should require non nill campaign code (db test)" do
    lambda {
      c = Campaign.new(@valid_attributes.merge({:campaign_code => nil}))
      c.save_with_validation(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require start_date of type date" do
    lambda {
      Campaign.create!(@valid_attributes.merge({:start_date => 3}))
    }.should raise_error
  end

  it "should require end_date of type date" do
    lambda {
      Campaign.create!(@valid_attributes.merge({:end_date => 3}))
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
