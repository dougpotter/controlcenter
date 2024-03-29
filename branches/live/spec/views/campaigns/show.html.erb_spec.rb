require 'spec_helper'

describe "/campaigns/show.html.erb" do
  before(:each) do
    @image1 = stub_everything(
      "Image1",
      :url => "/path/to/creative/1"
    )
    @creative_size1 = stub_everything(
      "CreativeSize1", 
      :common_name => "Wide Skyscraper"
    )
    @creative1 = stub_everything(
      "Creative1",
      :image => @image1, 
      :creative_size => @creative_size1
    )
    @image2 = stub_everything(
      "Image2",
      :url => "/path/to/creative/2"
    )
    @creative_size2 = stub_everything(
      "CreativeSize2", 
      :common_name => "Leaderboard"
    )
    @creative2 = stub_everything(
      "Creative2",
      :image => @image2,
      :creative_size => @creative_size2
    )
    @line_item = stub_everything(
      "Line Item",
      :name => "Line Item Name"
    )
    @audience = stub_everything(
      "Audience",
      :audience_code_and_description => "AUDC - desc"
    )
    @ais1 = stub_everything(
      "AIS1",
      :name => "Google AdX"
    )
    @ais2 = stub_everything(
      "AIS2",
      :name => "Burst OX"
    )
    @campaign = stub_everything(
      "Campaign",
      :campaign_code_and_description => "ABC - description",
      :line_item => @line_item,
      :source_type => "Ad-Hoc",
      :audience => @audience,
      :name => "campaign name",
      :campaign_code => "CACO",
      :campaign_type => "Ad-Hoc",
      :creatives => [ @creative1, @creative2 ],
      :ad_inventory_sources => [ @ais1, @ais2]
    )
    @campaign.expects(:segment_id_for).with(@ais1).returns("123")
    @campaign.expects(:segment_id_for).with(@ais2).returns("456")
    @creatives = [ @creative1, @creative2 ]
    assigns[:campaign] = @campaign
    assigns[:creatives] = @creatives
  end

  it "should render" do
    render
  end

  it "should render when no audience is associated" do
    @campaign.expects(:audience => nil)
    render
  end

  it "should contain heading of campaign code and description" do
    render
    response.should have_tag("h2", "ABC - description")
  end

  it "should contain description of campaign attributes" do
    render
    response.should have_tag("div") do
      with_tag("p", "Line Item: Line Item Name")
      with_tag("p", "Audience Type: Ad-Hoc")
      with_tag("p", "Audience: AUDC - desc")
      with_tag("p", "Campaign Name: campaign name")
      with_tag("p", "Campaign Code: CACO")
    end
  end

  it "should contain list - with heading \"Creatives\" - of associated creatives" do
    render
    response.should have_tag("h2", "Creatives") 
    response.should have_tag("div") do
      with_tag("img[src=\"/path/to/creative/1\"]")
      with_tag("img[src=\"/path/to/creative/2\"]")
    end
  end

  it "should contain list of AISes with heading \"Configured Ad" +
    " Inventory Sources\"" do
    render
    response.should have_tag("h2", "Configured Ad Inventory Sources")
    response.should have_tag("p", "Google AdX - 123")
    response.should have_tag("p", "Burst OX - 456")
    end

  it "should contain a button to edit the campaign" do
    render
    response.should have_tag("div") do
      with_tag("input[value=\"Edit Campaign\"]")
    end
  end
end
