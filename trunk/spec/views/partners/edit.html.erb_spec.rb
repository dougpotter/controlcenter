require 'spec_helper'

describe "/partners/edit.html.erb" do
  it "should render" do
    @partner = stub_everything("Partner", :class => Partner)
    @partner.expects(:id).times(3).returns(1)
    template.expects(:error_messages_for).returns(nil)
    @partner.expects(:class).times(4).returns(Partner)
    assigns[:partner] = @partner
    render
  end
end
