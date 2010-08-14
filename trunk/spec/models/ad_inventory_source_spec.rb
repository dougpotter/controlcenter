# == Schema Information
# Schema version: 20100813163534
#
# Table name: ad_inventory_sources
#
#  id       :integer(4)      not null, primary key
#  name     :string(255)
#  ais_code :string(255)     not null
#

require 'spec_helper'

describe AdInventorySource do
  before(:each) do
    @valid_attributes = {
      :name => "Google AdEx"
    }
  end

  it "should create a new instance given valid attributes" do
    AdInventorySource.create!(@valid_attributes)
  end
end
