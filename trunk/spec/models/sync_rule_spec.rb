require 'spec_helper'

describe SyncRule do
  before(:each) do
    @valid_attributes = {
      :secure_add_pixel => "ibtesting.dude",
      :secure_remove_pixel => "ibtesting.dude",
      :nonsecure_add_pixel => "ibtesting.dude",
      :nonsecure_remove_pixel => "ibtesting.dude",
      :sync_period => 7,
      :audience_id => 1 
    }
  end

  it "should create a new instance given valid attributes" do
    s = SyncRule.new(@valid_attributes)
    s.save_beacon.should == true
  end

  it "appnexus_conversion(conversion_id) should return the conversion pixel url" do
    SyncRule.apn_secure_conversion_pixel(1).should ==
      "<img src=\"https://secure.adnxs.com/px?id=1\" width=\"1\" height=\"1\" />"
  end

  it "appnexus_conversion(conversion_id) should return the conversion pixel url" do
    SyncRule.apn_nonsecure_conversion_pixel(1).should ==
      "<img src=\"http://ib.adnxs.com/px?id=1\" width=\"1\" height=\"1\" />"
  end
end
