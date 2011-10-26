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

  it "should delete free-standing (no associated line item or creative inventory" +
    "configs) creative when destroyed" do
    creative = Factory.create(:creative)

    expect {
      creative.destroy
    }.to change{ Creative.all.count}.by(-1)
    end

  it "should delete any associated creative inventory configs when destroyed" do
    creative = Factory.create(:creative)
    Factory.create(:creative_inventory_config, :creative_id => creative.id)

    expect {
      creative.destroy
    }.to change{ CreativeInventoryConfig.all.count}.by(-1)
  end

  it "should delete any associated relationships with line items when destroyed" do
    creative = Factory.create(
      :creative, 
      :line_items => [ Factory.create(:line_item) ]
    )

    creative.destroy
  end

  # a more thorough testing of this method exists in the specs for PixelGenerator
  describe "ae_pixels method" do
    fixtures :creatives,
      :creative_inventory_configs,
      :campaign_creatives,
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
  end

  describe "configured? method" do
    fixtures :creatives,
      :creative_inventory_configs,
      :campaign_creatives,
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

  describe "configure method" do
    fixtures :creatives,
      :creative_inventory_configs,
      :campaign_creatives,
      :campaigns, 
      :campaign_inventory_configs

    it "should configure creative for campaign-AIS combo when creative is not" + 
      "already configured" do
      caic = CampaignInventoryConfig.find(2)
      Creative.first.configured?(caic).should be_false
      Creative.first.configure(caic)
      Creative.first.configured?(caic).should be_true
      end

    it "should do nothing if creative is already configured" do
      caic = CampaignInventoryConfig.find(1)
      Creative.first.configured?(caic).should be_true
      Creative.first.configure(caic)
      Creative.first.configured?(caic).should be_true
    end
  end

  describe "unconfigure method" do
    it "should unconfigure creative if already configured"do
      caic = CampaignInventoryConfig.find(1)
      Creative.first.configured?(caic).should be_true
      Creative.first.unconfigure(caic)
      Creative.first.configured?(caic).should be_false
    end

    it "should do nothing if creative is not configured" do
      caic = CampaignInventoryConfig.find(2)
      Creative.first.configured?(caic).should be_false
      Creative.first.unconfigure(caic)
      Creative.first.configured?(caic).should be_false
    end
  end

  describe "#apn_json method" do
    fixtures :creatives,
      :creative_inventory_configs,
      :campaign_creatives,
      :campaigns, 
      :campaign_inventory_configs,
      :creative_sizes

    it "should return proper json" do
      # 'proper json' should simply translate all attributes stored in XGCC's 
      # database as well as append a flash_click_variable attribute (which is 
      # ignored by apn for filetypes other than flash) and a track_clicks attribute
      # which defaults to true
      @creative = Creative.new({
        :creative_size_id => CreativeSize.find_by_height_and_width("90", "728").id,
        :creative_code => "ZZ11",
        :image_file_name => "160x600_8F_Interim_final.gif",
        :image => File.open(File.join(
          RAILS_ROOT, 
          'public', 
          'images', 
          'for_testing', 
          '160x600_8F_Interim_final.gif')),
        :partner => Partner.first
      })

      @proper_json = ActiveSupport::JSON.encode({
        :creative => {
        :width => "728",
        :height => "90",
        :code => "ZZ11",
        :file_name => "160x600_8F_Interim_final.gif",
        :name => "160x600_8F_Interim_final.gif",
        :content => ActiveSupport::Base64.encode64(File.open(File.join(
          RAILS_ROOT, 
          'public', 
          'images', 
          'for_testing', 
          '160x600_8F_Interim_final.gif')).read),
        :format => "image",
        :flash_click_variable => "clickTag",
        :track_clicks => "true" }
      })

      ActiveSupport::JSON.decode(@creative.apn_json).should == ActiveSupport::JSON.decode(@proper_json)
    end
  end
end
