# == Schema Information
# Schema version: 20101220202022
#
# Table name: msas
#
#  id       :integer(4)      not null, primary key
#  msa_code :string(255)     not null
#  name     :string(255)
#

require 'spec_helper'

describe Msa do
  before(:each) do
  end

  it "should create a new instance given valid attributes" do
    Factory.create(:msa)
  end
end
