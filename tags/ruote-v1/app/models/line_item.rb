class LineItem < ActiveRecord::Base
  belongs_to :insertion_order
  has_and_belongs_to_many :custom_filters

  validates_numericality_of :impressions, :external_pricing, :internal_pricing, :insertion_order_id
end
