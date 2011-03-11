require 'spec_helper'

describe "/campaigns/show.html.erb" do
  before(:each) do
    @image1 = stub_everything(
      "Image1",
      :url => "/path/to/creative/1"
    )
    @creative1 = stub_everything(
      "Creative1",
      :image => @image1
    )
    @image2 = stub_everything(
      "Image2",
      :url => "/path/to/creative/2"
    )
    @creative2 = stub_everything(
      "Creative2",
      :image => @image2
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
      :campaign_type => "Ad-Hoc",
      :audience => @audience,
      :name => "campaign name",
      :campaign_code => "CACO",
      :campaign_type => "Ad-Hoc",
      :creatives => [ @creative1, @creative2 ],
      :aises => [ @ais1, @ais2]
    )
    assigns[:campaign] = @campaign
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
    response.should have_tag("h1", "ABC - description")
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
    response.should have_tag("h1", "Creatives") 
    response.should have_tag("div") do
      with_tag("img[src=\"/path/to/creative/1\"]")
      with_tag("img[src=\"/path/to/creative/2\"]")
    end
  end

  it "should contain list of configured AISes with heading \"Configured Ad" +
    " Inventory Sources\"" do
    render
    response.should have_tag("h1", "Configured Ad Inventory Sources")
    response.should have_tag("p", "Google AdX")
    response.should have_tag("p", "Burst OX")
    end

  it "should contain a link to edit the campaign" do
    render
    response.should have_tag("a", "Edit Campaign")
  end
end
