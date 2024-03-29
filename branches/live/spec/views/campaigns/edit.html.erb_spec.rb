require 'spec_helper'

describe "/campaigns/edit.html.erb" do
  include ViewHelperMethodHelper

  it "should render" do
    @campaign = stub_everything("Campaign")
    @campaign.expects(:class).times(4).returns(Campaign)
    @campaign.expects(:source_type).times(2).returns("ad-hoc")
    @campaign.expects(:new_record?).times(3).returns(false)
    @partner = stub_everything("Partner", :id => 1)
    @audience_source = stub_everything("Audience Source", :class => "AdHocSource")
    @campaign_types = [ @audience_source ]
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    template.expects(:creative_form_builder).returns("some javascript")
    assigns[:aises] = []
    assigns[:campaign] = @campaign
    assigns[:campaign_types] = @campaign_types
    assigns[:partner] = @partner
    render
  end
end
