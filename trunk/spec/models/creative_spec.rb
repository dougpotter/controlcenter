# == Schema Information
# Schema version: 20101220202022
#
# Table name: creatives
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  media_type         :string(255)
#  creative_size_id   :integer(4)      not null
#  creative_code      :string(255)     not null
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer(4)
#  image_updated_at   :datetime
#

require 'spec_helper'

describe Creative do

  it "should create a new instance given valid attributes" do
    Factory.create(:creative)
  end

  it "should require presence of creative_code (validations test)" do 
    lambda {
      Factory.create(:creative, :creative_code => nil)
    }.should raise_error
  end

  it "should require presence of creative_size_id (validations test)" do
    lambda {
      Factory.create(:creative, :creative_size_id => nil)
    }.should raise_error
  end

  it "should require presence of creative_code (db test)" do 
    lambda {
      c = Factory.build(:creative, :creative_code => nil)
      c.save(false)
    }.should raise_error
  end

  it "should require presence of creative_size_id (db test)" do
    lambda {
      c = Factory.build(:creative, :creative_size_id => nil)
      c.save(false)
    }.should raise_error
  end

  it "should require creative size id to be an integer (db test)" do
    lambda {
      c = Factory.build(:creative, :creative_size_id => "string")
      c.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require creative size id to be an integer (validation test)" do
    lambda {
      Factory.create(:creative, :creative_size_id => "string")
    }.should raise_error
  end

  it "should require unique creative_code (validations test)" do 
    lambda {
      Factory.create(:creative, :creative_code => "same")
      Factory.create(:creative, :creative_code => "same")
    }.should raise_error
  end

  it "should require unique creative_code (db test)" do
    lambda {
      Factory.create(:creative, :creative_code => "same")
      c = Factory.build(:creative, :creative_code => "same")
      c.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  # a more thorough testing of this method exists in the specs for PixelGenerator
  describe "ae_pixels method" do
    fixtures :creatives,
      :creative_inventory_configs,
      :campaigns_creatives,
      :campaigns, 
      :campaign_inventory_configs,
      :ad_inventory_sources,
      :line_items,
      :partners

    it "should return the full set of ae pixels for a given campaign" do
      creative = Creative.find(1)
      campaign = Campaign.find(1)
      pixels = creative.ae_pixels(campaign)

      pixels.should == [ 
        "http://xcdn.xgraph.net/1234/ae/xg.gif?type=ae&ais=AdX&pid=1234&cid=" +
        "ABC1&crid=AA11&mpm=cpm&evt=imp",
        "http://xcdn.xgraph.net/1234/ae/xg.gif?type=ae&ais=AdX&pid=1234&cid=" +
        "ABC1&crid=AA11&mpm=cpm&evt=eng",
        "http://xcdn.xgraph.net/1234/ae/xg.gif?type=ae&ais=AdX&pid=1234&cid=ABC1&" +
        "crid=AA11&mpm=cpm&evt=clk&n=http%3A%2F%2Fthelandingpageforcreativeone.com",
        "http://xcdn.xgraph.net/1234/ae/xg.gif?type=ae&ais=OX&pid=1234&cid=" + 
        "ABC1&crid=AA11&mpm=cpm&evt=imp",
        "http://xcdn.xgraph.net/1234/ae/xg.gif?type=ae&ais=OX&pid=1234&cid=" +
        "ABC1&crid=AA11&mpm=cpm&evt=eng",
        "http://xcdn.xgraph.net/1234/ae/xg.gif?type=ae&ais=OX&pid=1234&cid=ABC1&" +
        "crid=AA11&mpm=cpm&evt=clk&n=http%3A%2F%2Fthelandingpageforcreativeone.com"
      ]
    end

    describe "configured? method" do
      fixtures :creatives,
        :creative_inventory_configs,
        :campaigns_creatives,
        :campaigns, 
        :campaign_inventory_configs,
        :ad_inventory_sources

      describe "when the campaign portion of the campaign-AIS combo is" + 
        "associated with the creative" do

        it "should return true when this creative is configured on the given" +
          "campaign-AIS combination" do
          Creative.first.configured?(CampaignInventoryConfig.first).should be_true
          end
        it "should return false when creative is not configured on the given" +
          "campaign-AIS comgination" do
          Creative.find(2).configured?(
            CampaignInventoryConfig.find(2)
          ).should be_false
          end
        end

      describe "when the campaign portion of the campaign-AIS combo is not" +
        "associated with the creative" do

        it "should return false" do
          Creative.find(2).configured?(
            CampaignInventoryConfig.first
          ).should be_false
        end
      end
    end
  end
end
