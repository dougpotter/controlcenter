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
