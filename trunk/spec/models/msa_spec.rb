# == Schema Information
# Schema version: 20100819181021
#
# Table name: msas
#
#  id       :integer(4)      not null, primary key
#  msa_code :string(255)     not null
#

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
