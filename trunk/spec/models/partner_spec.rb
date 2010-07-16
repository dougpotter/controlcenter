require 'spec_helper'

describe Partner do
  before(:each) do
    @valid_attributes = {
      :name => "Soundspectrum",
    }
  end

  it "should create a new instance given valid attributes" do
    Partner.create!(@valid_attributes)
  end
end
