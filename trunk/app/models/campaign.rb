require 'custom_validations'
class Campaign < ActiveRecord::Base
  has_and_belongs_to_many :msas
  has_many :creatives
  belongs_to :partner
  has_and_belongs_to_many :ad_inventory_sources

  validates_numericality_of :partner_id, :cid
  # defined in lib/custom_validations.rb
  validates_as_date :start_date, :end_date
  validates_start_before_end :start_date, :end_date 

end
