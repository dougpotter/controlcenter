require 'spec_helper'

describe "/campaigns/edit.html.erb" do
  include ViewHelperMethodHelper

  it "should render" do
    @campaign = stub_everything("Campaign")
    @campaign.expects(:class).times(4).returns(Campaign)
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    template.expects(:options_for_select).
      returns(default_ofcfs_result)
    assigns[:campaign] = @campaign
    render
  end

  it "should include a Delete Campaign button" do
    @campaign = stub_everything("Campaign", :id => 1)
    @campaign.expects(:class).times(4).returns(Campaign)
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    template.expects(:options_for_select).
      returns(default_ofcfs_result)
    assigns[:campaign] = @campaign
    render
    response.should have_tag("form[action=/campaigns/#{@campaign.id}]") do
      with_tag "input[value=Delete Campaign]"
    end
  end
end
