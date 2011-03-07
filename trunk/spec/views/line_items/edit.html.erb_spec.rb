require 'spec_helper'

describe "/line_items/edit.html.erb" do
  include ViewHelperMethodHelper
  it "should render" do
    line_item = stub_everything("Line Item", :id => 1)
    line_item.expects(:class).times(4).returns(LineItem)
    template.expects(:error_messages_for).returns(nil)
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    assigns[:line_item] = line_item
    render
  end


  it "should contain a \"Delete Line Item\" button" do
    line_item = stub_everything("Line Item", :id => 1)
    line_item.expects(:class).times(4).returns(LineItem)
    template.expects(:error_messages_for).returns(nil)
    template.expects(:options_from_collection_for_select).
      returns(default_ofcfs_result)
    assigns[:line_item] = line_item
    render
    response.should have_tag("form[action=/line_items/#{line_item.id}]") do
      with_tag "input[value=Delete Line Item]"
    end
  end
end
