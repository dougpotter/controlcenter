require 'spec_helper'

describe "/ad_inventory_sources/edit.html.erb" do
  it "should render" do
    @ais = stub_everything("AIS")
    @ais.expects(:class).times(4).returns(AdInventorySource)
    template.expects(:error_messages_for).returns(nil)
    assigns[:ais] = @ais
    render
  end

  it "should have a Delete AIS button" do
    @ais = stub_everything("AIS", :id => 1)
    @ais.expects(:class).times(4).returns(AdInventorySource)
    template.expects(:error_messages_for).returns(nil)
    assigns[:ais] = @ais
    render
    response.should have_tag("form[action=/ad_inventory_sources/#{@ais.id}]") do
      with_tag "input[value=Delete AIS]"
    end
  end
end
