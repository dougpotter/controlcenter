require 'spec_helper'

describe CreativesController do

  describe "create with valid attributes" do

    it "should save a new creative associated with one campaign" do
      creative = mock(
        :creative_size_id= => 1, 
        :campaigns => [], 
        :attributes= => {}, 
        :save => true
      )
      Creative.expects(:new).returns(creative)
      campaign = mock()
      Campaign.expects(:find).with("1").returns(campaign)
      post :create, 
        :creative => { 
        :creative_size => "1", 
        :description => "desc", 
        :media_type => "flash", 
        :creative_code => "ACODE", 
        :campaigns => "1" 
      }
    end

    it "should save a new creative associated with multiple campaigns" do
      creative = mock(
        :creative_size_id= => 1, 
        :campaigns => [ [], ["1"] ], 
        :attributes= => {}, 
        :save => true
      )
      Creative.expects(:new).returns(creative)
      campaign = mock()
      Campaign.expects(:find).with([ '2', '1' ]).returns(campaign)
      post :create, 
        :creative => { 
        :creative_size => "1", 
        :description => "desc", 
        :media_type => "flash", 
        :creative_code => "ACODE", 
        :campaigns => ["2","1"] 
      }
    end

    it "should save a new creative not yet associated with any campaigns" do
      creative = mock(:creative_size_id= => 1, :attributes= => {}, :save => true)
      Creative.expects(:new).returns(creative)

      post :create, 
        :creative => { 
        :creative_size => "1", 
        :description => "desc", 
        :media_type => "flash", 
        :creative_code => "ACODE" 
      }
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
end
