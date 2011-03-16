require 'spec_helper'

describe AudiencesController, "create ad-hoc audience" do
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
        :audience_source => { :s3_bucket => "bucket:/a/path" }
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
