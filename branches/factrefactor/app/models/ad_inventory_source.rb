# == Schema Information
# Schema version: 20100819181021
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
  has_and_belongs_to_many :campaigns

  has_many :click_counts
  has_many :impression_counts

  validates_presence_of :ais_code

  acts_as_dimension
  business_index :ais_code, :aka => "ais"
end
