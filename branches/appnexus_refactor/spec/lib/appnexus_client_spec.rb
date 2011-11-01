require 'spec_helper'

describe AppnexusClient do
  fixtures :creatives,
    :creative_inventory_configs,
    :campaign_creatives,
    :campaigns,
    :campaign_inventory_configs,
    :creative_sizes,
    :partners

  before(:all) do
    @a = Curl::Easy.new
    @a.url = "http://sand.api.appnexus.com/auth"
    @a.enable_cookies = true
    @a.post_body = APN_CONFIG["authentication_hash"].to_json
    @a.http_post

    # create test advertiser if it does not already exist
    @a.url = APN_CONFIG["api_root_url"] + "advertiser?code=77777"
    @a.http_get
    if JSON.parse(@a.body_str)["response"]["error"] == "advertiser not found"
      @a.url = APN_CONFIG['api_root_url'] + 'advertiser'
      @a.post_body = attrs = { "advertiser" => { 
        :name => "Test Advertiser", :code => "77777" } }.to_json
      @a.http_post
    end

    # associate a conversion pixel with test advertiser if one deosn't already exist
    @a.url = APN_CONFIG["api_root_url"] + "pixel?advertiser_code=77777"
    @a.http_get
    if JSON.parse(@a.body_str)["response"]["pixels"].blank?
      @a.post_body = { :pixel => {
        :code => "77777",
        :name => "conversion for test advertiser",
        :state => "active" } }.to_json
      @a.http_post
    end
  end

  before(:each) do
    @creative = Creative.new({
      :creative_size_id => CreativeSize.find_by_height_and_width("90", "728").id,
      :creative_code => "ZZ11",
      :image_file_name => "160x600_8F_Interim_final.gif",
      :image => File.open(File.join(
        RAILS_ROOT,
        'public',
        'images',
        'for_testing',
        '160x600_8F_Interim_final.gif')),
      :partner => Partner.find_by_partner_code(77777)
    })
  end

  describe "apn_client_method" do
    it "should return the default method if no custom method exists" do
      Partner.apn_client_method("new").should == "new_advertiser"
    end

    it "should return the the custom method if one is defined" do
      ConversionPixel.apn_client_method("put").should == "update_pixel_by_code"
    end
  end

  describe "all_apn" do
    context "when called on Creative" do
      it "should return an array of all creatives in the Appnexus sandbox" do
        @a.url = APN_CONFIG["api_root_url"] + "creative"
        @a.http_get
        creatives = 
          ActiveSupport::JSON.decode(@a.body_str)["response"]["creatives"]

        Creative.all_apn.should == creatives
        end
    end

    context "when called on Partner" do
      it "should return an array of all the partners in the Appnexus sandbox" do
        @a.url = APN_CONFIG["api_root_url"] + "advertiser"
        @a.http_get
        partners = 
          ActiveSupport::JSON.decode(@a.body_str)["response"]["advertisers"]

        Partner.all_apn.should == partners
      end
    end

    context "when called on ConversionPixel" do
      it "should return an array of all the converison pixels in Appnexus" do
        @a.url = APN_CONFIG["api_root_url"] + "pixel?advertiser_code=77777"
        @a.http_get
        conversion_pixels = JSON.parse(@a.body_str)["response"]["pixels"]
        
        ConversionPixel.all_apn(77777).should == conversion_pixels
      end
    end
  end
=begin
  describe "delete_all_apn" do
    it "should delete all creatives when called on Creative class" do
      @creative.save
      @creative.save_apn
      Creative.delete_all_apn
      Creative.all_apn.size.should == 0
    end
  end

  describe "#delete_apn" do
    it "should delete this record from apnexus" do
      @creative.save
      @creative.save_apn

      @creative.delete_apn.should == true
    end
  end

  describe "methods that interact with apn" do
      after(:each) do
        Creative.delete_all_apn
      end

    describe "save_apn" do
      it "should return true if upload returns success message" do
        @creative.save_apn.should == true
      end

      it "should return false if upload returns error message" do
        @creative.image = nil
        @creative.save_apn.should == false
      end
    end

    describe "save_apn!" do
      it "should return true if upload returns success message" do
        @creative.save_apn!.should == true
      end

      it "should raise ActiveRecord::AppnexusRecordInvalid if upload returns error"+
        " message" do
        lambda {
          @creative.image = nil
          @creative.save_apn!
        }.should raise_error(AppnexusRecordInvalid)
        end
    end

    describe "update_attributes" do
      it "with valid attributes should update the appropriate record" do
        @creative.save_apn
        @creative.update_attributes(
          :image => File.open(File.join(
            RAILS_ROOT,
            'public',
            'images',
            'for_testing',
            '300x250_8F_Interim_final.gif' 
        )))
        @creative.update_attributes_apn
        agent = AppnexusClient::API.new_agent
        agent.url = Creative.apn_action_url(:view, @creative.creative_code)
        agent.http_get
        ActiveSupport::JSON.
          decode(agent.body_str)["response"]["creative"]["name"].should == 
          "300x250_8F_Interim_final.gif"
      end

      it "should create the creative if it doesn't already exist" do
        Creative.delete_all_apn
        @creative.update_attributes_apn
        agent = AppnexusClient::API.new_agent
        agent.url = Creative.apn_action_url(:view, @creative.creative_code)
        agent.http_get
        ActiveSupport::JSON.decode(agent.body_str)["response"]["status"].should == 
          "OK"
      end

      it "with valid attributes should return true" do
        @creative.save_apn
        @creative.update_attributes(
          :image => File.open(File.join(
            RAILS_ROOT,
            'public',
            'images',
            'for_testing',
            '300x250_8F_Interim_final.gif' 
        )))
        @creative.update_attributes_apn.should == true
      end

      it "with invalid attributes should return false" do
        @creative.partner = nil
        @creative.update_attributes_apn.should == false
      end
    end
  end
=end
end
