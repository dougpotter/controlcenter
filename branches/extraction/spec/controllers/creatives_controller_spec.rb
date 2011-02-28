require 'spec_helper'

describe CreativesController, "create with valid attributes" do

  it "should save a new creative associated with one campaign" do
    creative = mock(:creative_size_id= => 1, :campaigns => [], :attributes= => {}, :save => true)
    Creative.expects(:new).returns(creative)
    campaign = mock()
    Campaign.expects(:find).with("1").returns(campaign)
    post :create, :creative => { :creative_size => "1", :description => "desc", :media_type => "flash", :creative_code => "ACODE", :campaigns => "1" }

  end

  it "should save a new creative associated with multiple campaigns" do
    creative = mock(:creative_size_id= => 1, :campaigns => [ [], ["1"] ], :attributes= => {}, :save => true)
    Creative.expects(:new).returns(creative)
    campaign = mock()
    Campaign.expects(:find).with([ '2', '1' ]).returns(campaign)
    post :create, :creative => { :creative_size => "1", :description => "desc", :media_type => "flash", :creative_code => "ACODE", :campaigns => ["2","1"] }
  end

  it "should save a new creative not yet associated with any campaigns" do
    creative = mock(:creative_size_id= => 1, :attributes= => {}, :save => true)
    Creative.expects(:new).returns(creative)

    post :create, :creative => { :creative_size => "1", :description => "desc", :media_type => "flash", :creative_code => "ACODE" }
  end

end
