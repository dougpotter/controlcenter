require 'spec_helper'

describe CampaignsController do

  context "destroy" do
    it "should destroy the campaign with id passed in params[:id]" do
      @campaign = Factory.create(:campaign)
      Campaign.expects(:destroy).with(@campaign.id.to_s).returns(@campaign)
      delete :destroy, :id => @campaign.id
    end

    it "should redirect to campaign management index page" do
      @campaign = Factory.create(:campaign)
      delete :destroy, :id => @campaign.id
      response.should redirect_to(campaign_management_index_url)
    end
  end

  context "create" do

    context "ad-hoc campaign" do
      context "without creatives" do
        context "without AIS configs" do

          def do_create
            post :create,
              :campaign => {
              :name => "A New Campaign",
              :campaign_code => "ACODE",
              :line_item => "1" },
              :audience_source => {
              :s3_location => "/a/path/in/s3",
              :audience_code => "AB17" },
              :sync_rules => { "ApN" => { :apn_segment_id => "" } },
              :audience => { :audience_type => "Ad-Hoc" }
          end

          context "with valid attributes" do
            before(:each) do
              @partner = mock("Partner")
              @campaign = mock(
                "Campaign", 
                :update_attributes => true,
                :save => true
              )
              @line_item = mock("Line Item")
              LineItem.expects(:find).with("1").returns(@line_item)
              Campaign.expects(:new).with({
                "name" => "A New Campaign",
                "campaign_code" => "ACODE",
                "line_item" => @line_item
              }).returns(@campaign)
            end

            it "should assign @campaign" do
              do_create
              assigns(:campaign).should == @campaign
            end

            it "should associate audience with campaign" do
              @audience = stub_everything("Audience")
              Audience.expects(:find_by_audience_code).with("AB17").
                returns(@audience)
              do_create
            end

            it "should save @campaign" do
              do_create
            end

            it "response should redirect to show action" do
              do_create
              response.should redirect_to(campaign_path(@campaign))
            end
          end

          context "with invalid attributes" do
            before(:each) do
              @campaign = mock(
                "Campaign", 
                :save => false
              ) 
              @line_item = mock("Line Item")
            end

            it "should fail to save @campaign" do
              LineItem.expects(:find).with("1").returns(@line_item)
              Campaign.expects(:new).with({
                "name" => "A New Campaign",
                "campaign_code" => "ACODE",
                "line_item" => @line_item
              }).returns(@campaign)
              do_create
            end

            it "response should redirect to new campaign path" do
              LineItem.expects(:find).with("1").returns(@line_item)
              Campaign.expects(:new).with({
                "name" => "A New Campaign",
                "campaign_code" => "ACODE",
                "line_item" => @line_item
              }).returns(@campaign)
              do_create
              response.should redirect_to(new_campaign_path)
            end
          end
        end

        context "with AppNexus as AIS" do
          def do_create
            post :create,
              :campaign => {
              :name => "A New Campaign",
              :campaign_code => "ACODE",
              :line_item => "1" },
              :audience_source => {
              :s3_location => "/a/path/in/s3",
              :audience_code => "AB17" },
              :sync_rules => { "ApN" => { :apn_segment_id => "ACODE" } },
              :aises_for_sync => [ "ApN" ],
              :audience => { :audience_type => "Ad-Hoc" }
          end

          context "with valid attributes" do
            before(:each) do
              @partner = mock("Partner", :partner_code => "ACODE") 
              @campaign = mock(
                "Campaign", 
                :update_attributes => true,
                :partner => @partner, 
                :save => true
              ) 
              @line_item = mock("Line Item")
            end

            it "should save @campaign" do
              LineItem.expects(:find).with("1").returns(@line_item)
              Campaign.expects(:new).with({
                "name" => "A New Campaign",
                "campaign_code" => "ACODE",
                "line_item" => @line_item
              }).returns(@campaign)
              CampaignsController.any_instance.
                expects(:create_and_run_apn_sync_job).returns(true)
              do_create
            end

            it "should create and run apn sync job" do
              LineItem.expects(:find).with("1").returns(@line_item)
              Campaign.expects(:new).with({
                "name" => "A New Campaign",
                "campaign_code" => "ACODE",
                "line_item" => @line_item
              }).returns(@campaign)
              CampaignsController.any_instance.
                expects(:create_and_run_apn_sync_job).returns(true)
              do_create
              response.should_not have_text("invalid appnexus sync job")
            end

          end

          context "with invalid apn sync params" do
            before(:each) do
              @partner = mock("Partner", :partner_code => "ACODE") 
              @campaign = mock(
                "Campaign", 
                :partner => @partner, 
                :update_attributes => true,
                :save => true
              ) 
              @line_item = mock("Line Item")
            end

            it "should fail to create and run apn sync job" do
              LineItem.expects(:find).with("1").returns(@line_item)
              Campaign.expects(:new).with({
                "name" => "A New Campaign",
                "campaign_code" => "ACODE",
                "line_item" => @line_item
              }).returns(@campaign)
              CampaignsController.any_instance.
                expects(:create_and_run_apn_sync_job).returns(false)
              do_create
              response.should have_text("invalid appnexus sync job")
            end
          end
        end
      end
    end
  end

  describe "show" do
    it "should find the creative passed in params[:id]" do
      Campaign.expects(:find).with("1")
      get :show, :id => 1
    end
  end

  describe "update" do
    def do_update
      put :update, 
        :id => 1,
        :campaign => { 
          :name => "name",
          :campaign_type => "Ad-Hoc",
          :campaign_code => "ACODE",
          :line_item => "1" }
    end

    it "should update attributes of campaign passed in params[:id]" do
      @campaign = stub_everything("Campaign", :update_attributes => true)
      Campaign.expects(:find).with("1").returns(@campaign)
      do_update
    end

    it "should update audience source information"

  end
end
