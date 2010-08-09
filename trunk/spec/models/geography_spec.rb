# == Schema Information
# Schema version: 20100803143344
#
# Table name: geographies
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#

require 'spec_helper'

describe Geography do
  before(:each) do
    @valid_attributes = {
      :description => "value for description"
    }
  end

  it "should create a new instance given valid attributes" do
    Geography.create!(@valid_attributes)
  end
end
