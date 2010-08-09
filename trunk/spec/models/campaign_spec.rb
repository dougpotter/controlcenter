# == Schema Information
# Schema version: 20100803143344
#
# Table name: campaigns
#
#  id             :integer(4)      not null, primary key
#  description    :text            default(""), not null
#  campaign_code  :text            default(""), not null
#  partner_id     :integer(4)
#  cid            :integer(4)
#  time_window_id :integer(4)
#

require 'spec_helper'
require 'factory_girl'

describe Campaign do
  it "should create a new instance given valid attributes" do
    Factory.create(:campaign)
  end

  it "should require a parent partner" do
    lambda {
      Factory.create(:campaign, :partner_id => 100)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require non nill description (validations test)" do
    lambda {
      Factory.create(:campaign, :description => nil)
    }.should raise_error
  end

  it "should require non nill description (db test)" do
    lambda {
      c = Factory.build(:campaign, :description => nil)
      c.save_with_validation(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require non nill campaign code (validations test)" do
    lambda {
      Factory.create(:campaign, :campaign_code => nil)
    }.should raise_error
  end

  it "should require non nill campaign code (db test)" do
    lambda {
      c = Factory.build(:campaign, :campaign_code => nil)
      c.save_with_validation(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require integer partner_id" do
    lambda {
      Factory.create(:campaign, :partner_id => "not and int")
    }.should raise_error
  end

  it "should require integer cid" do
    lambda {
      Factory.create(:campaign, :cid => "not an int")
    }.should raise_error 
  end

  it "shoud require unique cid" do
    Factory.create(:campaign, :cid => "111")
    lambda {
      Factory.create(:campaign, :cid => "111")
    }.should raise_error
  end
end
