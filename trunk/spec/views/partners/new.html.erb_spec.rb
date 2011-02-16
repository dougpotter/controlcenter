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
    partner.expects(:class).times(4).returns(Partner)
    template.expects(:error_messages_for).returns("")
    assigns[:partners] = partners
    assigns[:partner] = partner
    render
  end
end
