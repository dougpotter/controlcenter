require 'spec_helper'

describe RetargetingConfiguration do
  before(:all) do
    if RAILS_ENV != "test"
      raise "RAILS_ENV IS NOT TEST!!!! IT IS #{RAILS_ENV} AND YOU SHOULD STOP."
    end
    for sp in SegmentPixel.all_apn
      if sp["advertiser_id"] == 29721
        SegmentPixel.new({
          :partner_id => 29721,
          :apn_id => sp["id"]
        }).delete_by_apn_id
      end
    end
    if audience = Audience.find_by_beacon_id(54321)
      audience.destroy
    end
    @partner_apn_id = Partner.new(:partner_code => 77777).find_apn["id"]
    @configured_beacon_audience = Hashie::Mash.new(
      :id => "12345",
      :name => "Beacon Test Audience",
      :pid => "77777")
    @configured_xgcc_audience = Audience.find_or_create_by_beacon_id(
      :description => "spec audience - configured", 
      :audience_code => Audience.generate_audience_code, 
      :beacon_id => @configured_beacon_audience["id"])
    SegmentPixel.new(
      :pixel_code => @configured_xgcc_audience.audience_code,
      :name => "spec segment pixel",
      :partner_id => "29721",
      :member_id => 821).save_apn!
    @configured_pixel_id = SegmentPixel.new(
      :pixel_code => @configured_xgcc_audience.audience_code).find_apn["id"]
    @unconfigured_beacon_audience = Hashie::Mash.new(
      :id => "54321",
      :name => "Beacon Test Audience - unconfigured",
      :pid => "77777")
    SegmentPixel.new(
      :name => "spec segment pixel - unconfigured",
      :partner_id => "29721",
      :member_id => 821).save_apn
    @unconfigured_pixel_id = SegmentPixel.all_apn.last["id"]
  end

  before(:each) do 
    if audience = Audience.find_by_beacon_id(54321)
      audience.destroy
    end
  end

  context "#ensure_audience_and_apn_pixel" do
    it "should raise an error when no pixel is present" do
      lambda {
        RetargetingConfiguration.ensure_audience_and_apn_pixel(
          @configured_beacon_audience, @partner_apn_id, 0)
      }.should raise_error(RuntimeError)
    end

    it "should not create an audience with no pixel present" do
      if audience = Audience.find_by_beacon_id(12345)
        audience.destroy
      end
      audience_count = Audience.count
      lambda {
        RetargetingConfiguration.ensure_audience_and_apn_pixel(
          @configured_beacon_audience, @partner_apn_id, 0)
      }.should raise_error(RuntimeError)
      Audience.count.should == audience_count
    end

    it "should create a new audience if one does not already exists with same "+
      "beacon id and pixel is present" do
      if audience = Audience.find(@configured_xgcc_audience.id)
        audience.destroy
      end
      audience_count = Audience.count
      RetargetingConfiguration.ensure_audience_and_apn_pixel(
        @configured_beacon_audience, @partner_apn_id, @configured_pixel_id)
      Audience.count.should == audience_count + 1
    end

    it "should update the pixel with the associated XGCC audience's audience code" do
      audience_count = Audience.count
      RetargetingConfiguration.ensure_audience_and_apn_pixel(
        @unconfigured_beacon_audience, @partner_apn_id, @unconfigured_pixel_id)
      Audience.count.should == audience_count + 1
      SegmentPixel.new(
        :partner_id => @partner_apn_id, 
        :apn_id => @unconfigured_pixel_id
      ).find_apn_by_id["code"].should == Audience.last.audience_code
    end
  end
end

