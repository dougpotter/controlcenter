require 'spec_helper'

describe "campaign_management/index.html.erb" do
  before(:each) do
    campaign = mock("Campaign")
    for method in [ :partner_name, :name, :campaign_code, :pretty_start_time, :pretty_end_time ]
      campaign.expects(method).times(2).returns("string")
    end
    campaign.expects(:id).times(5).returns(1)
    campaigns = [ campaign ]
    assigns[:campaigns] = campaigns
  end

  it "should render" do
    render
  end
end
