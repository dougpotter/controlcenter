require 'spec_helper'

describe CreativesController, "create with valid attributes" do

  before :each do
    @creative = mock_model(Creative)
    @creative_size = CreativeSize.new
    @campaign = mock_model(Campaign)
    @creative.should_receive(:creative_size_id=).with("1")
    @creative.should_receive(:attributes=).with({"media_type"=>"flash", "creative_code"=>"ACODE", "description"=>"desc"})
    @creative.should_receive(:save).and_return(true)
  end

  it "should save a new creative associated with one campaign" do
    @creative.should_receive(:campaigns).with().and_return(@campaign)
    @campaign.should_receive(:<<).with(@campaign)
    CreativeSize.expects(:find).with("1").returns(@creative_size)
    Campaign.expects(:find).with("1").returns(@campaign)
    Creative.expects(:new).returns(@creative)

    post :create, :creative => { :creative_size => "1", :description => "desc", :media_type => "flash", :creative_code => "ACODE", :campaigns => "1" }

  end

  it "should save a new creative associated with multiple campaigns" do
    @creative.should_receive(:campaigns).with().and_return(@campaign)
    @campaign.should_receive(:<<).with(@campaign)
    CreativeSize.expects(:find).with("1").returns(@creative_size)
    Campaign.expects(:find).with(["2","1"]).returns(@campaign)
    Creative.expects(:new).returns(@creative)

    post :create, :creative => { :creative_size => "1", :description => "desc", :media_type => "flash", :creative_code => "ACODE", :campaigns => ["2","1"] }
  end

  it "should save a new creative not yet associated with any campaigns" do
    CreativeSize.expects(:find).with("1").returns(@creative_size)
    Creative.expects(:new).returns(@creative)

    post :create, :creative => { :creative_size => "1", :description => "desc", :media_type => "flash", :creative_code => "ACODE" }
  end

end
