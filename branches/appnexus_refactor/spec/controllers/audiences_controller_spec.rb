require 'spec_helper'

describe AudiencesController, "create" do
  context  "any type of audience" do
    context "with a valid attributes" do

      before(:each) do 
        @audience = stub_everything("Audience")
        Audience.expects(:new).with(
          "audience_code" => "ACODE",
          "description" => "desc",
          "campaign_id" => 1
        ).returns(@audience)
      end

      def do_create
        post :create, 
          :audience => {
          :audience_code => "ACODE",
          :campaign_id => 1,
          :description => "desc" },
          :audience_source => { 
          :type => "AdHocSource"
        }
      end

      it "should create the Audience" do
        do_create
      end

      it "should save the audience" do
        @audience.expects(:save)
        do_create
      end

      it "should redirect to new audience page" do
        @audience.expects(:save).returns(true)
        do_create
        response.should redirect_to(new_audience_url)
      end
    end
  end

  context "an Ad-Hoc audience" do
    context "with valid attributes" do
      before(:each) do 
        @audience = stub_everything("Audience", :id => 1)
        Audience.expects(:new).with(
          "audience_code" => "ACODE",
          "description" => "desc",
          "campaign_id" => 1
        ).returns(@audience)
        @ad_hoc_source = stub_everything("Ad-Hoc Source", :id => 1)
        AdHocSource.expects(:new).with({ "s3_bucket" => "bucket:/a/path" }).
          returns(@ad_hoc_source)
      end

      def do_create
        post :create, 
          :audience => {
          :audience_code => "ACODE",
          :campaign_id => 1,
          :description => "desc" },
          :audience_source => { 
          :type => "AdHocSource",
          :s3_bucket => "bucket:/a/path"
        }
      end

      it "should create an ad-hoc audience source" do
        do_create
      end

      it "should create audience manifrest" do
        @audience.expects(:save).returns(true)
        @audience.expects(:<<).with(@ad_hoc_source)
        do_create
      end
    end
  end

  context "a Regargeting audience" do
    context "with valid attributes" do
      before(:each) do
        @audience = stub_everything("Audience", :id => 1)
        Audience.expects(:new).with(
          "audience_code" => "ACODE",
          "description" => "desc",
          "campaign_id" => 1
        ).returns(@audience)
        @ad_hoc_source = stub_everything("Retargeting Source", :id => 1)
        RetargetingSource.expects(:new).with({ 
          "referrer_regex" => "a*regex"
        }).returns(@ad_hoc_source)
      end

      def do_create
        post :create, 
          :audience => {
          :audience_code => "ACODE",
          :campaign_id => 1,
          :description => "desc" },
          :audience_source => { 
          :type => "RetargetingSource",
          :referrer_regex => "a*regex"
        }
      end

      it "should create retargeting audience source" do
        do_create
      end
    end
  end
end
