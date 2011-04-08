require 'spec_helper'

describe "creatives/new.html.erb" do

  before(:each) do
    creative = stub_everything("Creative", :partner_id => 1)
    creatives = stub_everything("Creatives")
    campaigns = stub_everything("Campaigns")
    creative_sizes = stub_everything("CreativeSizes")
    partners = [ Factory.create(:partner) ]

    creative.expects(:class).times(4).returns(Creative)

    assigns[:creative] = creative
    assigns[:creatives] = creatives
    assigns[:campaigns] = campaigns
    assigns[:creative_sizes] = creative_sizes
    assigns[:partners] = partners

    template.expects(:error_messages_for).returns(nil)
  end

  it "should contain an input field for file or directory location"

  it "should contain an input field for landing page URL" do
    render
    response.should have_tag("label[for=creative_landing_page_url]")
    response.should have_tag("input[id=creative_landing_page_url][type=text]")
  end

  it "should contain an select box for partner" do
    render
    response.should have_tag("label[for=creative_partner]")
    response.should have_tag("select[id=creative_partner]")
  end

  it "should contain a multi-select for campaign"
end
