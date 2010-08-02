# == Schema Information
# Schema version: 20100729211736
#
# Table name: line_items
#
#  id                 :integer(4)      not null, primary key
#  impressions        :integer(4)
#  internal_pricing   :float
#  external_pricing   :float
#  insertion_order_id :integer(4)
#

class LineItem < ActiveRecord::Base
  belongs_to :insertion_order
  has_and_belongs_to_many :custom_filters

  validates_numericality_of :impressions, :external_pricing, :internal_pricing, :insertion_order_id
end
