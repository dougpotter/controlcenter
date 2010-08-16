# == Schema Information
# Schema version: 20100816164408
#
# Table name: line_items
#
#  id                 :integer(4)      not null, primary key
#  impressions        :integer(4)
#  internal_pricing   :float
#  external_pricing   :float
#  insertion_order_id :integer(4)
#

# Line Item is defined as a component of an insertion order which
# specifies quantity and pricing of advertising to be delivered
class LineItem < ActiveRecord::Base
  belongs_to :insertion_order
  has_and_belongs_to_many :custom_filters

  validates_numericality_of :impressions, :external_pricing, :internal_pricing, :insertion_order_id
end
