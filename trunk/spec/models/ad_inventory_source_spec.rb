# == Schema Information
# Schema version: 20100819181021
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
      :name => "Google Adx",
      :ais_code => "AdX"
    }
  end

  it "should create a new instance given valid attributes" do
    AdInventorySource.create!(@valid_attributes)
    Factory.create(:ad_inventory_source)
  end
end
