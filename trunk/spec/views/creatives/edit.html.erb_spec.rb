require 'spec_helper'

describe "creatives/edit.html.erb" do
  it "should render" do
    creative = stub_everything("Creative", :errors => [], :campaigns => [])
    creative.expects(:class).times(4).returns(Creative)
    creative_sizes = stub_everything("CreativeSizes")
    template.expects(:collection_select).returns(
      "<option value=\"an option\"></option>")
    assigns[:creative] = creative 
    assigns[:creative_sizes] = creative_sizes
    render
  end

  it "should contain a delete button" do
    creative = stub_everything("Creative", :errors => [], :campaigns => [], :id => 1)
    creative.expects(:class).times(4).returns(Creative)
    creative_sizes = stub_everything("CreativeSizes")
    template.expects(:collection_select).returns(
      "<option value=\"an option\"></option>")
    assigns[:creative] = creative 
    assigns[:creative_sizes] = creative_sizes
    render
    response.should have_tag("form[action=/creatives/#{creative.id}]") do
      with_tag "input[value=Delete Creative]"
    end
  end
end
