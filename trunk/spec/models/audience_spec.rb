require 'spec_helper'

describe Audience do
  before(:each) do
    @valid_attributes = {
      :description => "3XM5",
      :internal_external => "external",
      :seed_extraction_id => 1,
      :model_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Audience.create!(@valid_attributes)
  end

  it "should require integer seed_extraction_id" do
    lambda {
    Audience.create!(@valid_addributes.merge([:seed_extraction_id => "not an int"]))
    }.should raise_error
  end

  it "should require integer model_id" do
    lambda {
    Audience.create!(@valid_addributes.merge([:model_id => "not an int"]))
    }.should raise_error
  end
end
