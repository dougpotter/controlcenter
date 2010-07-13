require 'spec_helper'

describe InsertionOrder do
  before(:each) do
    @valid_attributes = {
      :description => "description",
      :campaign_id => 3
    }
  end

  it "should create a new instance given valid attributes" do
    InsertionOrder.create!(@valid_attributes)
  end

  it "should require integer campaign_id" do
    lambda {
      InsertionOrder.create!(@valid_attributes.merge({:campaign_id => "string"}))
    }.should raise_error
  end
end
