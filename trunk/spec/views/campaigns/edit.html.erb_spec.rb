require 'spec_helper'

describe "/campaigns/edit.html.erb" do
  include ViewHelperMethodHelper

  it "should render" do
    @campaign = stub_everything("Campaign")
    @campaign.expects(:class).times(4).returns(Campaign)
    @campaign.expects(:source_type).times(2).returns("ad-hoc")
    @audience_source = stub_everything("Audience Source", :class => "AdHocSource")
    @campaign_types = [ @audience_source ]
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    assigns[:campaign] = @campaign
    assigns[:campaign_types] = @campaign_types
    render
  end

  it "should include a Delete Campaign button" do
    @campaign = stub_everything("Campaign", :id => 1)
    @campaign.expects(:class).times(4).returns(Campaign)
    @campaign.expects(:source_type).times(2).returns("ad-hoc")
    @audience_source = stub_everything("Audience Source", :class => "AdHocSource")
    @campaign_types = [ @audience_source ]
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    assigns[:campaign] = @campaign
    assigns[:campaign_types] = @campaign_types
    render
    response.should have_tag("form[action=/campaigns/#{@campaign.id}]") do
      with_tag "input[value=Delete Campaign]"
    end
  end
end
