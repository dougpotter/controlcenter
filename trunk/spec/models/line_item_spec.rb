# == Schema Information
# Schema version: 20100813163534
#
# Table name: line_items
#
#  id                 :integer(4)      not null, primary key
#  impressions        :integer(4)
#  internal_pricing   :float
#  external_pricing   :float
#  insertion_order_id :integer(4)
#

require 'spec_helper'

describe LineItem do
  before(:each) do
    @valid_attributes = {
      :impressions => 10000,
      :internal_pricing => 1.5,
      :external_pricing => 1.5,
      :insertion_order_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    LineItem.create!(@valid_attributes)
  end

  it "should require integer impressions" do
    lambda {
      LineItem.create!(@valid_attributes.merge({:impressions => "string"}))
    }.should raise_error
  end

  it "should require numerical pricing" do
    lambda {
      LineItem.create!(@valid_attributes.merge({:internal_pricing => "string"}))
      LineItem.create!(@valid_attributes.merge({:external_pricint => "string"}))
    }.should raise_error
  end

  it "should require numerical insertion_order_id" do
    lambda {
      LineItem.create!(@valid_attributes.merge({:insertion_order_id => "string"}))
    }.should raise_error
  end
end
