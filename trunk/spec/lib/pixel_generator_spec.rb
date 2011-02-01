require 'spec_helper'
describe PixelGenerator do
  describe "generate_pixel method" do
    fixtures :creatives,
      :creative_inventory_configs,
      :campaigns_creatives,
      :campaigns, 
      :campaign_inventory_configs,
      :ad_inventory_sources,
      :line_items,
      :partners

    before :each do
      @creative = Creative.find(1)
      @campaign_inventory_config = CampaignInventoryConfig.find(1)
    end

    it "should return the correct pixel when passed impression event_type" do
      pixel = PixelGenerator.generate_pixel(
        @creative, 
        "imp", 
        @campaign_inventory_config)

        pixel.should == "http://xcdn.xgraph.net/1234/ae/xg.gif?type=ae&ais=AdX&pid=1234&cid=ABC1&crid=AA11&mpm=cpm&evt=imp"
    end

    it "should return the correct pixel when passed engagement event_type" do
      pixel = PixelGenerator.generate_pixel(
        @creative, 
        "eng", 
        @campaign_inventory_config)

        pixel.should == "http://xcdn.xgraph.net/1234/ae/xg.gif?type=ae&ais=AdX&pid=1234&cid=ABC1&crid=AA11&mpm=cpm&evt=eng"
    end

    it "should return the correct pixel when passed click event_type" do
      pixel = PixelGenerator.generate_pixel(
        @creative, 
        "clk", 
        @campaign_inventory_config)

        pixel.should == "http://xcdn.xgraph.net/1234/ae/xg.gif?type=ae&ais=AdX&pid=1234&cid=ABC1&crid=AA11&mpm=cpm&evt=clk"
    end

    it "should return raise proper error when event_type is unknown" do
      lambda {
      pixel = PixelGenerator.generate_pixel(
        @creative, 
        "aaa", 
        @campaign_inventory_config)
      }.should raise_error(ArgumentError)
    end
  end
end
