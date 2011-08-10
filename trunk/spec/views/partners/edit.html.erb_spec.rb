require 'spec_helper'

describe "/partners/edit.html.erb" do
  it "should render" do
    @partner = stub_everything("Partner", :class => Partner)
    template.expects(:error_messages_for).returns(nil)
    @partner.expects(:class).times(4).returns(Partner)
    assigns[:partner] = @partner
    render
  end

  it "should contain Delete Advertiser button" do
    @partner = stub_everything("Partner", :id => 1, :class => Partner)
    template.expects(:error_messages_for).returns(nil)
    @partner.expects(:class).times(4).returns(Partner)
    assigns[:partner] = @partner
    render
    response.should have_tag("form[action=/partners/#{@partner.id}]") do
      with_tag "input[value=Delete Advertiser]"
    end
  end
end
