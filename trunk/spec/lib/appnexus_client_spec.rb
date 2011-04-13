require 'spec_helper'

describe AppnexusClient do
  include AppnexusClientHelper

  fixtures :creatives,
    :creative_inventory_configs,
    :campaigns_creatives,
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
      proper_url = "https://api.displaywords.com/creative?advertiser_code=8675309"
      Creative.apn_action_url(:new, ["8675309"]).should ==
        "https://api.displaywords.com/creative?advertiser_code=8675309"
    end

    it "should correctly compile array when passed a string of one substitution" do
      proper_url = "https://api.displaywords.com/creative?advertiser_code=8675309"
      Creative.apn_action_url(:index, "8675309").should ==
        "https://api.displaywords.com/creative?advertiser_code=8675309"
    end


    it "should correctly compile array when passed an array of multiple" + 
      " substitutions" do
      proper_url = "https://api.displaywords.com/creative?advertiser_code=8675309"
      Creative.apn_action_url(:delete, ["8675309", "12345"]).should ==
        "https://api.displaywords.com/creative?advertiser_code=8675309&code=12345"
    end
  end

  describe "#apn_action_url" do
    it "should correctly substitute one value " do
      proper_url = "https://api.displaywords.com/creative?advertiser_code=77777"
      @creative.apn_action_url(:new).should == proper_url
    end

    it "should correctly substitute multiple values" do
      proper_url = 
        "https://api.displaywords.com/creative?advertiser_code=77777&code=ZZ11"
      @creative.apn_action_url(:delete).should == proper_url
    end
  end

  describe "methods that interact with apn" do

    after(:each) do
      remove_all_test_creatives_from_apn
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
  end
end
