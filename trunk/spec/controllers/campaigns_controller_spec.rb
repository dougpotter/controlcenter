require 'spec_helper'

describe CampaignsController do
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
              :sync_rule => { "ApN" => { :apn_segment_id => "" } },
              :aises_for_sync => [""],
              :audience => { :audience_type => "Ad-Hoc" }
          end

          context "with valid attributes" do
            before(:each) do
              @partner = mock("Partner", :partner_code => "ACODE")
              @campaign = mock("Campaign", :save => true, :partner => @partner)
              @line_item = mock("Line Item")
            end

            it "should assign @campaign" do
              LineItem.expects(:find).with("1").returns(@line_item)
              Campaign.expects(:new).with({
                  "name" => "A New Campaign",
                  "campaign_code" => "ACODE",
                  "line_item" => @line_item
              }).returns(@campaign)
              do_create
              assigns(:campaign).should == @campaign
            end

            it "should save @campaign" do
              LineItem.expects(:find).with("1").returns(@line_item)
              Campaign.expects(:new).with({
                  "name" => "A New Campaign",
                  "campaign_code" => "ACODE",
                  "line_item" => @line_item
              }).returns(@campaign)
              do_create
            end

            it "response should redirect to campaign management" do
              LineItem.expects(:find).with("1").returns(@line_item)
              Campaign.expects(:new).with({
                  "name" => "A New Campaign",
                  "campaign_code" => "ACODE",
                  "line_item" => @line_item
              }).returns(@campaign)
              do_create
              response.should redirect_to(campaign_management_index_path)
            end
          end

          context "with invalid attributes" do
            before(:each) do
              @partner = mock("Partner") 
              @campaign = mock("Campaign", :save => false) 
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
      end
    end
  end
end
