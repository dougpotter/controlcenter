require 'spec_helper'

describe CampaignsController do

  fixtures :campaigns,
    :creatives,
    :campaign_creatives,
    :audiences,
    :ad_inventory_sources,
    :creative_inventory_configs,
    :creative_sizes,
    :line_items,
    :partners

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
                :line_item_id => "1" },
              :audience_attributes => {
                :audience_code => "AB17",
                :description => "an audience name",
                :audience_source_attributes => { 
                  "0" => {
                    :s3_bucket => "/a/path/in/s3",
                    :type => "Ad-Hoc" } } },
              :sync_rules => { "ApN" => { :apn_segment_id => "" } }
          end

          context "with valid attributes" do
            before(:each) do
              @partner = mock("Partner")
              @campaign = mock("Campaign", :save => true, :creatives => [])
              @line_item = mock("Line Item")
              @ad_hoc_source = mock("Ad Hoc Source")
              Campaign.expects(:new).returns(@campaign)
            end

            it "should assign @campaign" do
              do_create
              assigns(:campaign).should == @campaign
            end

            it "should associate audience with campaign" do
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
              @line_item = mock("Line Item")
              @campaign = mock("Campaign", :save => false, :creatives => []) 
              @ais = mock("Ad Inventory Source")
              LineItem.expects(:all).returns([])
              AdInventorySource.expects(:find_by_ais_code).returns(@ais)
              AudienceSource.expects(:all).returns([])
              Campaign.expects(:new).returns(@campaign)
            end

            it "should fail to save @campaign" do
              do_create
            end

            it "response should render new campaign action" do
              do_create
              response.should render_template(:new)
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
              :audience_attributes => {
                :audience_code => "AB17",
                :description => "an audience name",
                :audience_source_attributes => { 
                  "0" => {
                    :s3_bucket => "/a/path/in/s3",
                    :type => "Ad-Hoc" } } },
              :sync_rules => { "ApN" => { :apn_segment_id => "ACODE" } },
              :aises_for_sync => [ "ApN" ]
          end

          context "with valid attributes" do
            before(:each) do
              @campaign_inventory_config = mock("Campaign Inventory Config")
              @campaign = mock(
                "Campaign", 
                :configure_ais => @campaign_inventory_config,
                :creatives => [],
                :save => true
              ) 
              @line_item = mock("Line Item")
              @ad_hoc_source = mock(
                "Ad Hoc Source"
              )
              Campaign.expects(:new).returns(@campaign)
            end

            it "should save @campaign" do
              do_create
            end

            it "should create and run apn sync job" do
              do_create
              response.should_not have_text("invalid appnexus sync job")
            end

          end
        end
      end
    end
  end

  describe "show with no creatives" do
    it "should find the creative passed in params[:id]" do
      @campaign = mock("Campaign", :creatives => [])
      Campaign.expects(:find).with("1").returns(@campaign)
      get :show, :id => 1
    end
  end

  describe "update" do
    context "an Ad-Hoc campaign" do
      context "source s3 bucket" do
        def do_update
          put :update, 
            :id => 1,
            :campaign => { 
              :name => "name",
              :campaign_type => "Ad-Hoc",
              :campaign_code => "ACODE",
              :line_item_id => "1",
              :audience_attributes => {
                :id => "2",
                :description => "an audience name",
                :audience_code => "ACODE",
                :ad_hoc_source_attributes => { 
                  :old_s3_bucket => "bucket:/a/path",
                  :new_s3_bucket => "bucket:/b/path" } } },
            :audience_action => {
              :refresh => "1" },
            :sync_rules => {
              :ApN => {
                "appnexus_segment_id" => "12345" }}
        end

        it "should update attributes of campaign passed in params[:id]" do
          @audience = stub_everything("Audience")
          @campaign = stub_everything(
            "Campaign", 
            :update_attributes => true,
            :audience => @audience
          )
          Campaign.expects(:find).with("1").returns(@campaign)
          do_update
        end

        it "should update audience source s3_bucket and nothing more" do
          @campaign = stub_everything(
            "Campaign", 
            :update_attributes => true,
            :has_audience? => true
          )
          Campaign.expects(:find).returns(@campaign)
          do_update
        end

        context "with a creative disassociation" do
          def do_update
            put :update,
              :id => 1,
              :campaign => { 
                :name => "name",
                :campaign_type => "Ad-Hoc",
                :campaign_code => "ACODE",
                :line_item_id => "1",
                :creatives_attributes => {
                 "0" => {
                    :name => "A Name",
                    :media_type => "Flash",
                    :id => "1",
                    :creative_code => "ACODE",
                    :partner_id => "1",
                    :landing_page_url => "google.com",
                    :creative_size_id => "1" },
                 "1" => {
                    :id => "2",
                    :_disassociate => "true" } },
                :audience_attributes => {
                  :id => "1",
                  :description => "an audience name",
                  :ad_hoc_source_attributes => { 
                    :old_s3_bucket => "bucket:/a/path",
                    :new_s3_bucket => "" } } },
              :audience_action => {
                :refresh => "1" },
              :sync_rules => {
                :ApN => {
                  "appnexus_segment_id" => "12345" }}
          end

          it "should not disassociate any creatives not marked for disassociation" do
            do_update
            Campaign.find(1).creatives.collect { 
              |c| c.id 
            }.member?(1).should be_true
          end

          it "should disassociate any creatives marked for disassociation" do
            do_update
            Campaign.find(1).creatives.collect { 
              |c| c.id 
            }.member?(0).should be_false
          end
        end
      end
    end

    context "a Retargeting campaign" do
      context "with a brand new source" do
        def do_update
          put :update, 
            :id => 1,
            :campaign => { 
              :name => "name",
              :campaign_type => "Ad-Hoc",
              :campaign_code => "ACODE",
              :line_item_id => "1" },
            :audience_attributes => {
              :id => "2",
              :audience_code => "ACODE",
              :description => "an audience name",
              :audience_source_attributes => { 
                "0" => {
                  :referrer_regex => "a\.*regex",
                  :type => "Retargeting" } } },
            :sync_rules => {
              :ApN => {
                "appnexus_segment_id" => "12345" }}
        end

        before(:each) do
          @line_item = stub_everything("LineItem")
        end

        it "should update attributes of campaign passed in params[:id]" do
          @audience = stub_everything("Audience")
          @campaign = stub_everything(
            "Campaign", 
            :update_attributes => true,
            :audience => @audience
          )
          Campaign.expects(:find).with("1").returns(@campaign)
          do_update
        end

        it "should update audience source information" do
          @audience_source = mock("Audience Source")
          @campaign = stub_everything(
            "Campaign", 
            :update_attributes => true
          )
          Campaign.expects(:find).returns(@campaign)
          do_update
        end
      end
    end
  end
end
