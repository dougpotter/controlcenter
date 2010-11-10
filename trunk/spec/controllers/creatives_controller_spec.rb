require 'spec_helper'

describe CreativesController, "create with valid attributes" do

  def do_create
    post :create, :creative => { :creative_size => "1", :description => "desc", :media_type => "flash", :creative_code => "ACODE", :campaigns => "1" }
  end

  it "should save the new creative" do
    creative = Creative.new
    creative_size = CreativeSize.new
    campaign = Campaign.new
    CreativeSize.expects(:find).with("1").returns(creative_size)
    Campaign.expects(:find).with("1").returns(campaign)
    Creative.expects(:new).with({"creative_code" => "ACODE", "description" => "desc", "media_type" => "flash"}).returns(creative)
    creative.expects(:save).returns(true)
    do_create
  end
end
