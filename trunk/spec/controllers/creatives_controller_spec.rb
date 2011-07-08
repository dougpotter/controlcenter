require 'spec_helper'

describe CreativesController do

  describe "create with valid attributes" do
    before(:each) do
      @creative = mock(
        "Creative",
        :save => true
      )

      @basic_create_hash = {
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
              '160x600_8F_Interim_final.gif' )) }}
    end

    it "should save a new creative associated with one campaign" do
      Creative.expects(:new).returns(@creative)
      post :create, @basic_create_hash
    end

    it "should save a new creative associated with multiple campaigns" do
      Creative.expects(:new).returns(@creative)
      post :create, @basic_create_hash 
    end

    it "should save a new creative not yet associated with any campaigns" do
      Creative.expects(:new).returns(@creative)

      post :create, @basic_create_hash
    end
  end

  describe "index with valid attributes" do
    fixtures :partners, :campaigns

    it "should list proper creatives when passed a partner_id in params" do
      post :index, :partner_id => 1
      assigns[:partner_creatives].size.should == 2
      assigns[:partner_creatives].first == Creative.find(1)
      assigns[:campaign_creatives].size.should == 0
      assigns[:unassociated_creatives].size.should == 0
      assigns[:unassociated_creatives].first == Creative.find(2)
    end

    it "should list the proper creatives when passed a campaign_code in params" do
      post :index, :campaign_code => "ABC1"
      assigns[:partner_creatives].size.should == 0
      assigns[:campaign_creatives].size.should == 2
      assigns[:campaign_creatives].first == Creative.find(1)
      assigns[:unassociated_creatives].size.should == 0
      assigns[:unassociated_creatives].first == Creative.find(2)
    end

    it "should list the proper creatives when passed no partner_id in params" do
      post :index
      assigns[:partner_creatives].size.should == 0
      assigns[:campaign_creatives].size.should == 0
      assigns[:unassociated_creatives].size.should == 0
      assigns[:unassociated_creatives].first == Creative.find(2)
    end
  end

  describe "index_by_advertiser" do
    fixtures :partners, :campaigns, :creatives, :campaign_creatives, :line_items

    it "should select proper creatives when passed a valid partner_id" do
      get :index_by_advertiser, :partner_id => 1
      assigns[:creatives].size.should == 2
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
    context " with valid attributes" do 
      def do_update
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
      end

      it "should redirect to new creative page" do
        pending
        do_update
        response.should redirect_to(new_creative_url)
      end

      context " with invalid attributes" do
        it "should re-render the edit form"
      end
    end
  end
end
