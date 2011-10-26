require 'spec_helper'

describe SyncRule do
  before(:all) do
    @valid_beacon_audience_id = Beacon.new.audiences.first["id"]
    # ensure segment with code AAAA exists and store it's ID
    @seg_id = ""
    if @seg_id = SegmentPixel.all_apn.select { |px| px["code"] == "AAAA" }[0]["id"]
      # we're good, one exists with code AAAA
    else
      SegmentPixel.new(:name => "for testing", :pixel_code => "AAAA").save_apn!
      @seg_id = SegmentPixel.all_apn.select { |px| px["code"] == "AAAA" }[0]["id"]
    end

    # ensure conversion pixel (for Test Advertiser) with code AAAA exists and
    # store it's ID
    @px_id = ""
    if pixel = ConversionPixel.all_apn(:partner_code => 77777).select { |px| 
      px["code"] == "AAAA" 
    }[0]
      @px_id = pixel["id"]
    else
      ConversionPixel.new(
        :name => "for testing", 
        :pixel_code => "AAAA", 
        :partner_code => "77777"
      ).save_apn!
      @px_id = ConversionPixel.all_apn(:partner_code => 77777).select { |px| 
        px["code"] == "AAAA" 
      }[0]["id"]
    end
  end

  before(:each) do
    @valid_attributes = {
      :secure_add_pixel => "ibtesting.dude",
      :secure_remove_pixel => "ibtesting.dude",
      :nonsecure_add_pixel => "ibtesting.dude",
      :nonsecure_remove_pixel => "ibtesting.dude",
      :sync_period => 7,
      :audience_id => @valid_beacon_audience_id
    }
  end

  it "should create a new instance given valid attributes" do
    s = SyncRule.new(@valid_attributes)
    s.save_beacon.should == true
  end

  it "apn_secure_pixel(conversion_id, type) should return the conversion "+
  "pixel url" do
    SyncRule.apn_secure_pixel(1, "px").should ==
      "https://secure.adnxs.com/px?id=1&t=2"
  end

  it "apn_nonsecure_pixel(conversion_id, type) should return the conversion "+
  "pixel url" do
    SyncRule.apn_nonsecure_pixel(1, "px").should ==
      "http://ib.adnxs.com/px?id=1&t=2"
  end

  it "#apn_secure_add_conversion(partner_code, pixel_code) should return the"+
  " secure add pixel for appnexus" do
    SyncRule.apn_secure_add_conversion("77777", "AAAA").should ==
      "https://secure.adnxs.com/px?id=#{@px_id}&t=2"
  end

  it "#apn_nonsecure_add_conversion(partner_code, pixel_code) should return "+
  "the nonsecure add pixel for appnexus" do
    SyncRule.apn_nonsecure_add_conversion("77777", "AAAA").should ==
      "http://ib.adnxs.com/px?id=#{@px_id}&t=2"
  end

  it "#apn_secure_add_segment(partner_code, pixel_code) should return the"+
  " secure add pixel for appnexus" do
    SyncRule.apn_secure_add_segment("AAAA").should ==
      "https://secure.adnxs.com/seg?id=#{@seg_id}"
  end

  it "#apn_nonsecure_add_segment(partner_code, pixel_code) should return "+
  "the nonsecure add pixel for appnexus" do
    SyncRule.apn_nonsecure_add_segment("AAAA").should ==
      "http://ib.adnxs.com/seg?id=#{@seg_id}"
  end
end
