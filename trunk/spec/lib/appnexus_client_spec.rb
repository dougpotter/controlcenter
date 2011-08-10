require 'spec_helper'

describe AppnexusClient do
  fixtures :creatives,
    :creative_inventory_configs,
    :campaign_creatives,
    :campaigns,
    :campaign_inventory_configs,
    :creative_sizes,
    :partners

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

  describe "apn_action_url (class method)" do
    it "shoud raise an error when number of macros and substitutions don't match" do
      lambda {
        Creative.apn_action_url(:new, ["too", "many", "cookies"])
      }.should raise_error
    end

    it "should correctly compile array when passed an array of one substitution" do
      proper_url = "http://hb.sand-08.adnxs.net/creative?advertiser_code=8675309"
      Creative.apn_action_url(:new, ["8675309"]).should ==
        "http://hb.sand-08.adnxs.net/creative?advertiser_code=8675309"
    end

    it "should correctly compile array when passed a string of one substitution" do
      proper_url = "http://hb.sand-08.adnxs.net/creative?advertiser_code=8675309"
      Creative.apn_action_url(:index_by_advertiser, "8675309").should ==
        "http://hb.sand-08.adnxs.net/creative?advertiser_code=8675309"
    end


    it "should correctly compile array when passed an array of multiple" + 
      " substitutions" do
      proper_url = "http://hb.sand-08.adnxs.net/creative?advertiser_code=8675309"
      Creative.apn_action_url(:delete, ["8675309", "12345"]).should ==
        "http://hb.sand-08.adnxs.net/creative?advertiser_code=8675309&code=12345"
    end
  end

  describe "#apn_action_url" do
    it "should correctly substitute one value " do
      proper_url = "http://hb.sand-08.adnxs.net/creative?advertiser_code=77777"
      @creative.apn_action_url(:new).should == proper_url
    end

    it "should correctly substitute multiple values" do
      proper_url = 
        "http://hb.sand-08.adnxs.net/creative?advertiser_code=77777&code=ZZ11"
      @creative.apn_action_url(:delete).should == proper_url
    end

    it "should substitute the blank string for undefined attributes" do
      proper_url = "http://hb.sand-08.adnxs.net/creative?advertiser_code="
      @creative.partner = nil
      @creative.apn_action_url(:new).should == proper_url
    end
  end

  describe "all_apn" do
    context "when called on Creative" do
      it "should return an array of all creatives in the Appnexus sandbox" do
        agent = AppnexusClient::API.new_agent
        agent.url = Creative.apn_action_url(:index)
        agent.http_get
        creatives = 
          ActiveSupport::JSON.decode(agent.body_str)["response"]["creatives"]

        Creative.all_apn.should == creatives
        end
    end

    context "when called on Partner" do
      it "should return an array of all the partners in the Appnexus sandbox" do
        agent = AppnexusClient::API.new_agent
        agent.url = Partner.apn_action_url(:index)
        agent.http_get
        partners = 
          ActiveSupport::JSON.decode(agent.body_str)["response"]["advertisers"]

        Partner.all_apn.should == partners
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
