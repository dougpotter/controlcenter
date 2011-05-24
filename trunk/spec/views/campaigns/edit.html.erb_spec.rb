require 'spec_helper'

describe "/campaigns/edit.html.erb" do
  include ViewHelperMethodHelper

  it "should render" do
    @campaign = stub_everything("Campaign")
    @campaign.expects(:class).times(4).returns(Campaign)
    @campaign.expects(:source_type).times(3).returns("ad-hoc")
    @campaign.expects(:new_record?).times(3).returns(false)
    @audience_source = stub_everything("Audience Source", :class => "AdHocSource")
    @campaign_types = [ @audience_source ]
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    assigns[:aises] = []
    assigns[:campaign] = @campaign
    assigns[:campaign_types] = @campaign_types
    render
  end
end
