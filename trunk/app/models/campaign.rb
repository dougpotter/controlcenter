require 'custom_validations'
class Campaign < ActiveRecord::Base
  has_and_belongs_to_many :msas
  has_many :creatives
  belongs_to :partner
  has_and_belongs_to_many :ad_inventory_sources
  
  # custom validations defined in lib/custom_validations.rb
  validates_presence_of :description, :campaign_code
  validates_uniqueness_of :cid
  validates_numericality_of :partner_id, :cid
  validates_as_date :start_date, :end_date, {:allow_nil => true}
  validates_as_increasing :start_date, :end_date, {:allow_nil => true}
end
