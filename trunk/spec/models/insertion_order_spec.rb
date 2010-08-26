# == Schema Information
# Schema version: 20100819181021
#
# Table name: insertion_orders
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  campaign_id :integer(4)
#

require 'spec_helper'
# this test fails at the moment, but this model is of low priority
# i'll come back to it
describe InsertionOrder do

  it "should create a new instance given valid attributes" do
    Factory.create(:insertion_order)
  end

end
