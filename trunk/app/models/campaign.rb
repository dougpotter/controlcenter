# == Schema Information
# Schema version: 20100729211736
#
# Table name: campaigns
#
#  id             :integer(4)      not null, primary key
#  description    :text            default(""), not null
#  campaign_code  :text            default(""), not null
#  partner_id     :integer(4)
#  cid            :integer(4)
#  time_window_id :integer(4)
#

class Campaign < ActiveRecord::Base
  has_and_belongs_to_many :geographies
  has_and_belongs_to_many :ad_inventory_sources
  has_many :creatives
  belongs_to :partner
  
  validates_presence_of :description, :campaign_code
  validates_uniqueness_of :cid
  validates_numericality_of :partner_id, :cid
end
