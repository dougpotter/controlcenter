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

  describe "compiled_url" do

    it "should correctly substitute values for macros" do
      proper_url = 
        APN_CONFIG["displaywords_urls"]["creative"]["new"].
        gsub("###", @creative.partner_code)

      @creative.compiled_url(:new).should == proper_url
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
