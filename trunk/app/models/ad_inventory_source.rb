# == Schema Information
# Schema version: 20100803143344
#
# Table name: ad_inventory_sources
#
#  id   :integer(4)      not null, primary key
#  name :text
#

# Ad Inventory Source is defined as an entity from which we buy 
# advertising inventory. Examples as of today (08-03-2010) are Ad
# Exchange, Ad Conductor, and Open Exchange
class AdInventorySource < ActiveRecord::Base
  has_and_belongs_to_many :campaigns
end
