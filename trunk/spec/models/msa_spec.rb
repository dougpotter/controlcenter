require 'spec_helper'

describe Msa do
  before(:each) do
    @valid_attributes = {
      :country => "value for country",
      :region => "value for region"
    }
  end

  it "should create a new instance given valid attributes" do
    Msa.create!(@valid_attributes)
  end
end
