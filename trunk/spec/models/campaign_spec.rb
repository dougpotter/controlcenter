# == Schema Information
# Schema version: 20100819181021
#
# Table name: campaigns
#
#  id            :integer(4)      not null, primary key
#  description   :string(255)     default(""), not null
#  campaign_code :string(255)     default(""), not null
#  partner_id    :integer(4)
#  start_time    :datetime
#  end_time      :datetime
#

require 'spec_helper'
require 'factory_girl'

describe Campaign do
  it "should create a new instance given valid attributes" do
    Factory.create(:campaign)
  end

  it "should require a parent line item" do
    lambda {
      Factory.create(:campaign, :line_item_id => 100)
    }.should raise_error(ActiveRecord::ActiveRecordError)
  end

  it "should require non null campaign code (validations test)" do
    lambda {
      Factory.create(:campaign, :campaign_code => nil)
    }.should raise_error
  end

  it "should require non null campaign code (db test)" do
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

  it "shoud require unique cid" do
    Factory.create(:campaign, :campaign_code => "111")
    lambda {
      Factory.create(:campaign, :campaign_code => "111")
    }.should raise_error
  end
end
