require 'spec_helper'

describe Creative do
  before(:each) do
    @valid_attributes = {
      :name => "Very Creative",
      :media_type => "banner",
      :creative_size_id => 2,
      :campaign_id => 1,
    }
  end

  it "should create a new instance given valid attributes" do
    Creative.create!(@valid_attributes)
  end

  it "should require creative size id to be integer" do
    lambda {
      Creative.create!(@valid_attributes.merge({ :creative_size_id => "not int" }))
    }.should raise_error
  end

  it "should require campaign id to be integer" do
    lambda {
      Creative.create!(@valid_attributes.merge({ :campaign_id => "not int" }))
    }.should raise_error
  end
end
