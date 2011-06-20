require 'spec_helper'

describe "campaigns/new.html.erb" do
  it "should render" do
    line_item = mock("Line Item", :id => 1)
    campaign = mock(
      "campaign",
      :line_item_id => line_item.id,
      :name => "campaign name",
      :id => 1,
      :campaign_code => "ACODE",
      :source_type => "Ad-Hoc"
    )
    audience = mock(
      "Audience", 
      :audience_code => "CODE", 
      :description => "desc"
    )
    audience_source = mock("Audience Source", :s3_bucket => nil)
    campaign_type = mock("Campaign Type", :class => "AdHocSource")
    campaign_types = mock(
      "Campaign Types",
      :each => nil,
      :first => campaign_type
    )
    campaign.expects(:errors).times(7).returns([])
    campaign.expects(:audience_sources).times(4).returns([])
    campaign.expects(:ad_inventory_sources).twice.returns([])
    campaign.expects(:has_audience?).twice.returns(true)
    campaign.expects(:new_record?).times(3).returns(true)
    adx = mock("adx")
    adx.expects(:ais_code).times(12).returns("ACODE")
    aises = [ adx ]
    campaign.expects(:class).times(4).returns(Campaign)
    template.expects(:options_from_collection_for_select).
      returns("<option value=\"12\">Unclassified Line Item</option>")
    assigns[:aises] = aises
    assigns[:campaign] = campaign
    assigns[:campaign_types] = campaign_types
    assigns[:audience] = audience
    assigns[:audience_source] = audience_source
    render
  end
end
