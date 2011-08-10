require 'spec_helper'

describe "partners/new.html.erb" do
  it "should render" do
    partners = mock(
      "partners",
      :empty? => true
    )
    partner = mock(
      "partner",
      :partner_code => "",
      :name => ""
    )
    partner.expects(:class).times(8).returns(Partner)
    partner.expects(:id).times(2).returns(1)
    template.expects(:error_messages_for).returns("")
    assigns[:partners] = partners
    assigns[:partner] = partner
    render
  end
end
