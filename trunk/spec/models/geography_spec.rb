# == Schema Information
# Schema version: 20100819181021
#
# Table name: geographies
#
#  id         :integer(4)      not null, primary key
#  country_id :integer(4)      not null
#  msa_id     :integer(4)      not null
#  zip_id     :integer(4)      not null
#  region_id  :integer(4)      not null
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
