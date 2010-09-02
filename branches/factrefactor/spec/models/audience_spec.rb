# == Schema Information
# Schema version: 20100819181021
#
# Table name: audiences
#
#  id            :integer(4)      not null, primary key
#  description   :string(255)
#  audience_code :string(255)     not null
#

require 'spec_helper'

describe Audience do

  it "should create a new instance given valid attributes" do
    Factory.create(:audience)
  end

  it "should require an audience code" do
    lambda {
      Factory.create(:audience, :audience_code => nil)
    }.should raise_error
  end

  it "should require a unique audience code (validations test)" do
    lambda {
      Factory.create(:audience, :audience_code => "same")
      Factory.create(:audience, :audience_code => "same")
    }.should raise_error
  end

  it "should require a unique audience code (db test)" do
    lambda {
      Factory.create(:audience, :audience_code => "same")
      f = Factory.build(:audience, :audience_code => "same")
      f.save(false)
    }.should raise_error
  end

  it "should require non null audience code (validations test)" do
    lambda {
      Factory.create(:audience, :audience_code => nil)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require non null audience code (db test)" do
    lambda {
      a = Factory.build(:audience, :audience_code => nil)
      a.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end
end
