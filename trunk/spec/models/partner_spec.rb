# == Schema Information
# Schema version: 20100803143344
#
# Table name: partners
#
#  id   :integer(4)      not null, primary key
#  name :string(255)
#

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
