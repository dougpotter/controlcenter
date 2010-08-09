# == Schema Information
# Schema version: 20100803143344
#
# Table name: creative_sizes
#
#  id     :integer(4)      not null, primary key
#  height :float
#  width  :float
#

require 'spec_helper'

describe CreativeSize do
  before(:each) do
    @valid_attributes = {
      :height => 1.5,
      :width => 1.5
    }
  end

  it "should create a new instance given valid attributes" do
    CreativeSize.create!(@valid_attributes)
  end

  it "should require float height" do
    lambda {
    CreateiveSize.create!(@valid_attributes.merge({:height => "string"}))
    }.should raise_error
  end

  it "should require float width" do
    lambda {
    CreateiveSize.create!(@valid_attributes.merge({:width => "string"}))
    }.should raise_error
  end
end
