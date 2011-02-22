require 'spec_helper'

describe "campaign_management/index.html.erb" do
  it "should render" do
    template.expects(:options_from_collection_for_select).
      returns("<option value=\"1\">A Partner</option>")
    template.expects(:options_from_collection_for_select).
      returns("<option value=\"1\">An AIS</option>")
    campaign = mock("Campaign", 
      :campaign_code_and_description => "ACODE - Description")
    campaigns = [ campaign ]
    assigns[:campaigns] = campaigns
    render
  end

  context "after successful campaign creation" do
    it "should show campaign successfully created" do
    template.expects(:options_from_collection_for_select).
      returns("<option value=\"1\">A Partner</option>")
    template.expects(:options_from_collection_for_select).
      returns("<option value=\"1\">An AIS</option>")
    campaign = mock("Campaign", 
      :campaign_code_and_description => "ACODE - Description")
    campaigns = [ campaign ]
    assigns[:campaigns] = campaigns
    flash[:notice] = "campaign successfully created"
    render
    response.should have_tag("div", "campaign successfully created")
    end
  end
end
