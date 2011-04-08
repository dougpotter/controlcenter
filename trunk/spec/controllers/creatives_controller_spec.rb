require 'spec_helper'

describe CreativesController do

  describe "create with valid attributes" do

    it "should save a new creative associated with one campaign" do
      partner = mock("Partner", :partner_code => "ACODE")
      creative = mock(
        "Creative",
        :campaigns => [], 
        :attributes= => {}, 
        :partner => partner,
        :save => true
      )
      Creative.expects(:new).returns(creative)
      campaign = mock("campaign")
      Campaign.expects(:find).with("1").returns(campaign)
      controller.expects(:apn_new).returns(true)

      post :create, 
        :creative => { 
          :creative_size => "1", 
          :name => "name", 
          :media_type => "flash", 
          :partner => "1",
          :image => File.open(
            File.join(
              RAILS_ROOT, 
              'public', 
              'images', 
              'for_testing', 
              '160x600_8F_Interim_final.gif' )),
          :campaigns => "1" }
    end

    it "should save a new creative associated with multiple campaigns" do
      partner = mock("Partner", :partner_code => "ACODE")
      creative = mock(
        "creative",
        :attributes= => {},
        :partner => partner,
        :save => true
      )
      campaign_one = mock("campaign_one")
      campaign_two = mock("campaign_two")
      creative.expects(:campaigns).twice.returns([], [campaign_one])
      Creative.expects(:new).returns(creative)
      Campaign.expects(:find).twice.returns(campaign_one, campaign_two)
      controller.expects(:apn_new).returns(true)

      post :create, 
        :creative => { 
          :creative_size => "1", 
          :name => "name", 
          :media_type => "flash", 
          :partner => "1",
          :image => File.open(
            File.join(
              RAILS_ROOT, 
              'public', 
              'images', 
              'for_testing', 
              '160x600_8F_Interim_final.gif' )),
          :campaigns => ["1","2"] }
    end

    it "should save a new creative not yet associated with any campaigns" do
      partner = mock("Partner", :partner_code => "ACODE")
      creative = mock(
        "Creative",
        :attributes= => {}, 
        :save => true,
        :partner => partner
      )
      Creative.expects(:new).returns(creative)
      controller.expects(:apn_new).returns(true)

      post :create, 
        :creative => { 
          :creative_size => "1", 
          :name => "name", 
          :media_type => "flash", 
          :partner => "1",
          :image => File.open(
            File.join(
              RAILS_ROOT, 
              'public', 
              'images', 
              'for_testing', 
              '160x600_8F_Interim_final.gif' )),
          :creative_code => "ACODE" }
    end
  end

  describe "index with valid attributes" do
    fixtures :partners, :campaigns

    it "should list proper creatives when passed a partner_id in params" do
      post :index, :partner_id => 1
      assigns[:partner_creatives].size.should == 1
      assigns[:partner_creatives].first == Creative.find(1)
      assigns[:campaign_creatives].size.should == 0
      assigns[:unassociated_creatives].size.should == 1
      assigns[:unassociated_creatives].first == Creative.find(2)
    end

    it "should list the proper creatives when passed a campaign_code in params" do
      post :index, :campaign_code => "ABC1"
      assigns[:partner_creatives].size.should == 0
      assigns[:campaign_creatives].size.should == 1
      assigns[:campaign_creatives].first == Creative.find(1)
      assigns[:unassociated_creatives].size.should == 1
      assigns[:unassociated_creatives].first == Creative.find(2)
    end

    it "should list the proper creatives when passed no partner_id in params" do
      post :index
      assigns[:partner_creatives].size.should == 0
      assigns[:campaign_creatives].size.should == 0
      assigns[:unassociated_creatives].size.should == 1
      assigns[:unassociated_creatives].first == Creative.find(2)
    end
  end

  describe "index_by_advertiser" do
    fixtures :partners, :campaigns, :creatives

    it "should select proper creatives when passed a valid partner_id" do
      get :index_by_advertiser, :partner_id => 1
      assigns[:creatives].size.should == 1
      assigns[:creatives].first.should == Creative.find(1)
    end
  end

  describe "destroy" do

    it "should assign removed creative to creatives" do
      creative = Factory.create(:creative)
      delete :destroy, :id => creative.id
      assigns[:creative].should == creative
    end

    it "should remove proper creative from database" do
      creative = Factory.create(:creative)
      Creative.expects(:find).with(creative.id.to_s).
        returns(mock("Creative", :destroy => self))
      delete :destroy, :id => creative.id
    end
  end

  describe "update" do
    it "should redirect to new creative page" do
      put :update,
        :id => "1",
        :creative => { 
          :creative_size => "1", 
          :name => "name", 
          :media_type => "flash", 
          :creative_code => "ACODE", 
          :campaigns => "1",
          :partner => "1",
          :image => File.open(
            File.join(
              RAILS_ROOT, 
              'public', 
              'images', 
              'for_testing', 
              '160x600_8F_Interim_final.gif'
            ))}

      response.should redirect_to(new_creative_url)
    end
  end
end
