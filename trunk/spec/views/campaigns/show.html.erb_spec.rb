require 'spec_helper'

describe "/campaigns/show.html.erb" do
  before(:each) do
    @line_item = stub_everything(
      "Line Item",
      :name => "Line Item Name"
    )
    @audience = stub_everything(
      "Audience",
      :audience_code_and_description => "AUDC - desc"
    )
    @campaign = stub_everything(
      "Campaign",
      :campaign_code_and_description => "ABC - description",
      :line_item => @line_item,
      :campaign_type => "Ad-Hoc",
      :audience => @audience,
      :name => "campaign name",
      :campaign_code => "CACO"
    )
  end

  it "should render" do
    assigns[:campaign] = @campaign
    render
  end

  it "should render when no audience is associated" do
    @campaign.expects(:audience => nil)
    assigns[:campaign] = @campaign
    render
  end

  it "should contain heading of campaign code and description" do
    assigns[:campaign] = @campaign
    render
    response.should have_tag("h1", "ABC - description")
  end

  it "should contain description of campaign attributes" do
    assigns[:campaign] = @campaign
    render
    response.should have_tag("div") do
      with_tag("p", "Line Item: Line Item Name")
      with_tag("p", "Audience Type: Ad-Hoc")
      with_tag("p", "Audience: AUDC - desc")
      with_tag("p", "Campaign Name: campaign name")
      with_tag("p", "Campaign Code: CACO")
    end
  end
end
