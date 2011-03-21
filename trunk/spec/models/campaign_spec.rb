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

  it "should remove associated campaign_inventory_configs when destroyed" do
    lambda {
      c = Factory.create(:campaign)
      c.ad_inventory_sources << Factory.create(:ad_inventory_source)
      campaign_inventory_config_id = c.campaign_inventory_configs[0].id
      c.destroy
      CampaignInventoryConfig.find(campaign_inventory_config_id)
    }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should remove relationships with associated creatives when destroyed" do
    campaign = Factory.create(:campaign)
    creative = Factory.create(:creative)
    creative_id = creative.id
    creative_id = creative.id
    campaign.creatives << creative
    campaign.destroy
    Creative.find(creative_id).campaigns.should == []
  end

  it "should not remove associated creatives when destroyed (just relatinoship)" do
    campaign = Factory.create(:campaign)
    creative = Factory.create(:creative)
    creative_id = creative.id
    campaign.creatives << creative
    campaign.destroy
    Creative.find(creative_id).should == creative
  end

  it "should remove relationship with audience when destroyed" do
    campaign = Factory.create(:campaign)
    audience = Factory.create(:audience, :campaign_id => campaign.id)
    audience_id = audience.id
    campaign.destroy
    Audience.find(audience_id).campaign_id.should == nil
  end

  it "should not remove associated audience when destoryed (just relationship)" do
    campaign = Factory.create(:campaign)
    audience = Factory.create(:audience, :campaign_id => campaign.id)
    audience_id = audience.id
    campaign.destroy
    Audience.find(audience_id).should == audience
  end

  context "\#update_audience_source" do
    it "should raise exception if campaign has no audience" do
      campaign = Factory.create(:campaign)
      audience_source = Factory.create(:ad_hoc_source)
      lambda {
        campaign.update_audience_source(audience_source)
      }.should raise_error
    end

    it "should create a new audience manifest with iteration number 0 when called for first time with an Ad-Hoc Source" do
      campaign = Factory.create(:campaign)
      audience = Factory.create(:audience)
      campaign.audience = audience
      campaign.save
      audience_source = Factory.create(:ad_hoc_source)
      campaign.update_audience_source(audience_source)
    end
  end

  context "\#audience_sources" do
    it "should return nil if the campaign has no audience" do
      campaign = Factory.create(:campaign)
      campaign.audience_sources.should == nil
    end

    it "should return the audience source if the campaign has one" do
      ad_hoc_source = Factory.create(:ad_hoc_source)
      audience = Factory.create(:audience, :audience_sources => [ ad_hoc_source ])
      campaign = Factory.create(:campaign, :audience => audience)
      campaign.audience_sources.should == [ ad_hoc_source ]
    end

    it "should return empty array if the campaign has an audience with no source" do
      audience = Factory.create(:audience)
      campaign = Factory.create(:campaign, :audience => audience)
      campaign.audience_sources.should == []
    end
  end

  describe "with dimension cache" do 
    fixtures :creatives, 
      :campaigns, 
      :line_items, 
      :ad_inventory_sources, 
      :audiences, 
      :campaigns_creatives, 
      :campaign_inventory_configs,
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
