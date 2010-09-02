# == Schema Information
# Schema version: 20100819181021
#
# Table name: creatives
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)
#  media_type       :string(255)
#  creative_size_id :integer(4)
#  campaign_id      :integer(4)
#  creative_code    :string(255)     not null
#

require 'spec_helper'

describe Creative do

  it "should create a new instance given valid attributes" do
    Factory.create(:creative)
  end

  it "should require presence of creative_code (validations test)" do 
    lambda {
      Factory.create(:creative, :creative_code => nil)
    }.should raise_error
  end

  it "should require presence of creative_size_id (validations test)" do
    lambda {
      Factory.create(:creative, :creative_size_id => nil)
    }.should raise_error
  end

  it "should require presence of creative_code (db test)" do 
    lambda {
      c = Factory.build(:creative, :creative_code => nil)
      c.save(false)
    }.should raise_error
  end

  it "should require presence of creative_size_id (db test)" do
    lambda {
      c = Factory.build(:creative, :creative_size_id => nil)
      c.save(false)
    }.should raise_error
  end

  it "should require creative size id to be an integer (db test)" do
    lambda {
      c = Factory.build(:creative, :creative_size_id => "string")
      c.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should require creative size id to be an integer (validation test)" do
    lambda {
      Factory.create(:creative, :creative_size_id => "string")
    }.should raise_error
  end

  it "should require unique creative_code (validations test)" do 
    lambda {
      Factory.create(:creative, :creative_code => "same")
      Factory.create(:creative, :creative_code => "same")
    }.should raise_error
  end

  it "should require unique creative_code (db test)" do
    lambda {
      Factory.create(:creative, :creative_code => "same")
      c = Factory.build(:creative, :creative_code => "same")
      c.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end
end
