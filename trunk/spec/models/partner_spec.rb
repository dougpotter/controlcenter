# == Schema Information
# Schema version: 20100819181021
#
# Table name: partners
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)
#  partner_code :integer(4)      not null
#

require 'spec_helper'

describe Partner do
  before(:each) do
    @valid_attributes = {
      :name => "Eye-fi",
      :partner_code => "11380"
    }
  end

  it "should create a new instance given valid attributes" do
    Partner.create!(@valid_attributes)
    Factory.create(:partner)
  end
end
