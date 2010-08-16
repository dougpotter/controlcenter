# == Schema Information
# Schema version: 20100816164408
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

  def business_code
    :ais_code
  end

  def self.code_to_pk(ais_code)
    find_by_ais_code(ais_code).id
  end
end
