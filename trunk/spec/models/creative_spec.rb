# == Schema Information
# Schema version: 20100813163534
#
# Table name: creatives
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)
#  media_type       :string(255)
#  creative_size_id :integer(4)
#  campaign_id      :integer(4)
#  creative_code    :string(255)     not null
#

require 'spec_helper'

describe Creative do
  before(:each) do
    @creative_size = CreativeSize.new({
      :height => 100, 
      :width => 200, 
    })
    @creative_size.save
    @partner = Partner.new({ 
      :name => "name"
    }) 
    @partner.save
    @campaign = Campaign.new({
      :description => "monster campaign",
      :campaign_code => "XG8100",
      :start_date => Date.today,
      :end_date => Date.today + 1,
      :partner_id => @partner.id,
      :cid => 1
    } )
    @campaign.save
    @valid_attributes = {
      :name => "Very Creative",
      :media_type => "banner",
      :creative_size_id => @creative_size.id,
      :campaign_id => @campaign.id,
    }
  end

  it "should create a new instance given valid attributes" do
    Creative.create!(@valid_attributes)
  end

  it "should require creative size id to be an integer (db test)" do
    lambda {
      c = Creative.new(@valid_attributes.merge({:creative_size_id => "str"}))
      c.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require campaign id to be an integer (db test)" do
    lambda {
      c = Creative.new(@valid_attributes.merge({:campaign_id => "str"}))
      c.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require creative size id to be an integer (validation test)" do
    lambda {
      Creative.create!(@valid_attributes.merge({ :creative_size_id => "not int" }))
    }.should raise_error
  end

  it "should require campaign id to be an integer (validation test)" do
    lambda {
      Creative.create!(@valid_attributes.merge({ :campaign_id => "not int" }))
    }.should raise_error
  end
end
