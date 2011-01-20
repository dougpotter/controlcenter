# == Schema Information
# Schema version: 20101220202022
#
# Table name: campaigns
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)     default(""), not null
#  campaign_code :string(255)     default(""), not null
#  start_time    :datetime
#  end_time      :datetime
#  line_item_id  :integer(4)      not null
#

require 'spec_helper'
require 'factory_girl'

describe Campaign do
  it "should create a new instance given valid attributes" do
    Factory.create(:campaign)
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

  describe "with dimension cache" do 
    fixtures :creatives, 
      :campaigns, 
      :line_items, 
      :ad_inventory_sources, 
      :audiences, 
      :campaigns_creatives, 
      :ad_inventory_sources_campaigns,
      :creative_sizes

    it "should add relationship with line item to dimension cache" do
      c = Campaign.new({
        :name => "third campaign", 
        :campaign_code => "A3C1", 
        :line_item_id => 1
      })
      c.save!
      CACHE.read("campaign_id:#{c.id}:line_item_id:1").should == true
    end
  end
end
