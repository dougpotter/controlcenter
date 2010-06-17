require 'spec_helper'

describe Partner do
  before(:each) do
    @valid_attributes = {
      :name => "Soundspectrum",
      :pid => 10551
    }
  end

  it "should create a new instance given valid attributes" do
    Partner.create!(@valid_attributes)
  end
  
  it "should require a non-empty PID" do
    lambda { 
      Partner.create!(@valid_attributes.merge({ :pid => nil }))
    }.should raise_error
  end
  
  it "should require an integer PID" do
    lambda { 
      Partner.create!(@valid_attributes.merge({ :pid => "soundspectrum" }))
    }.should raise_error
  end
  
  it "should require a unique PID" do
    Partner.create!(@valid_attributes)
    lambda { 
      Partner.create!(@valid_attributes)
    }.should raise_error
  end
end
