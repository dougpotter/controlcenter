# == Schema Information
# Schema version: 20100729211736
#
# Table name: insertion_orders
#
#  id          :integer(4)      not null, primary key
#  description :text
#  campaign_id :integer(4)
#

class InsertionOrder < ActiveRecord::Base
  belongs_to :campaign

  validates_numericality_of :campaign_id
end
