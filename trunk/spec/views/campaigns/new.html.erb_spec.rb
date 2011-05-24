require 'spec_helper'

describe "campaigns/new.html.erb" do
  it "should render" do
    line_item = mock()
    campaign = mock(
      "campaign",
      :line_item => line_item,
      :name => "campaign name",
      :id => 1,
      :campaign_code => "ACODE",
      :source_type => "Ad-Hoc"
    )
    campaign_type = mock(:class => "AdHocSource")
    campaign_types = mock(
      :first => campaign_type
    )
    campaign.expects(:errors).times(4).returns([])
    campaign.expects(:audience_sources).twice.returns([])
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
    render
  end
end
