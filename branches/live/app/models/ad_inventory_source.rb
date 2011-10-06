# == Schema Information
# Schema version: 20101220202022
#
# Table name: ad_inventory_sources
#
#  id       :integer(4)      not null, primary key
#  name     :string(255)
#  ais_code :string(255)     not null
#

# Ad Inventory Source is defined as an entity from which we buy 
# advertising inventory. Examples as of today (08-03-2010) are Ad
# Exchange, Ad Conductor, and Open Exchange
class AdInventorySource < ActiveRecord::Base
  has_many :campaign_inventory_configs, :dependent => :delete_all
  has_many :campaigns, :through => :campaign_inventory_configs

  has_many :click_counts
  has_many :impression_counts

  has_many :creative_inventory_configs
  has_many :creatives, :through => :creative_inventory_configs

  validates_presence_of :ais_code
  validates_uniqueness_of :ais_code

  acts_as_dimension
  business_index :ais_code, :aka => "ais"
end
