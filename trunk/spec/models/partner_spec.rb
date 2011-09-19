# == Schema Information
# Schema version: 20101220202022
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
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should require non null partner_code (db test)" do
    lambda {
      p = Factory.build(:partner, :partner_code => nil)
      p.save(false)
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it "should accept nested attributes for action tags" do 
    p = Factory.create(:partner)
    Factory.create(
      :partner, 
      :action_tags_attributes => { "0" => Factory.build(:action_tag, :partner_id => p.id).attributes })
  end

  it "should raise error with out-of-range partner code" do
    lambda {
      Factory.create(:partner, :partner_code => "99999")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end
end
