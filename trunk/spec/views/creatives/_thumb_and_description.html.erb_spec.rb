require 'spec_helper'

describe "/creatives/_thumb_and_description.html.erb" do
  it "should contain creative code and name" do
    @image = stub_everything("Image", :url => "/path/to/image")
    @creative = stub_everything(
      "Creative", 
      :creative_code_and_name => "ACODE - name",
      :image => @image
    )
    assigns[:creative] = @creative
    render
    response.should have_tag("p", "ACODE - name")
  end

  it "should contain a photo of the creative" do
    @image = stub_everything("Image", :url => "/path/to/image")
    @creative = stub_everything(
      "Creative",
      :image => @image
    )
    assigns[:creative] = @creative
    render
    response.should have_tag("img[src=\"/path/to/image\"]")
  end
end
