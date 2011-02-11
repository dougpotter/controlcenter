require 'spec_helper'

describe "campaigns/new.html.erb" do
  it "should render" do
    campaign = mock(
      "campaign",
      :line_item_id => "1",
      :name => "campaign name",
      :campaign_code => "ACODE"
    )
    adx = mock("adx")
    adx.expects(:ais_code).times(10).returns("ACODE")
    aises = [ adx ]
    campaign.expects(:class).times(4).returns(Campaign)
    template.expects(:options_from_collection_for_select).
      returns("<option value=\"12\">Unclassified Line Item</option>")
    template.expects(:options_for_select).
      returns("<option value=\"Ad-Hoc\">Ad-Hoc</option>" +
              "<option value=\"Retargeting\">Retargeting</option>")
    assigns[:aises] = aises
    assigns[:campaign] = campaign
    render
  end
end
