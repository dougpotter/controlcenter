require 'spec_helper'

describe "/partners/edit.html.erb" do
  it "should render" do
    @partner = stub_everything("Partner", :class => Partner)
    @partner.expects(:id).times(4).returns(1)
    template.expects(:error_messages_for).returns(nil)
    @partner.expects(:class).times(4).returns(Partner)
    assigns[:partner] = @partner
    render
  end

  it "should contain Delete Advertiser button" do
    @partner = stub_everything("Partner", :class => Partner)
    @partner.expects(:id).times(5).returns(1)
    template.expects(:error_messages_for).returns(nil)
    @partner.expects(:class).times(4).returns(Partner)
    assigns[:partner] = @partner
    render
    response.should have_tag("a[href=/partners/#{@partner.id}]")
  end
end
