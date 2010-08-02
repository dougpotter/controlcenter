# == Schema Information
# Schema version: 20100729211736
#
# Table name: ad_inventory_sources
#
#  id   :integer(4)      not null, primary key
#  name :text
#

class AdInventorySource < ActiveRecord::Base
  has_and_belongs_to_many :campaigns
end
