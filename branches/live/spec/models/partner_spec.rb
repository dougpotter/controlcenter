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

  it "should create a new instance given valid attributes" do
    Factory.create(:partner)
  end

  it "should require non null partner_code (validations test)" do
    lambda {
      Factory.create(:partner, :partner_code => nil)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require non null partner_code (db test)" do
    lambda {
      p = Factory.build(:partner, :partner_code => nil)
      p.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end
end
