# == Schema Information
# Schema version: 20100729211736
#
# Table name: creatives
#
#  id               :integer(4)      not null, primary key
#  name             :text
#  media_type       :text
#  creative_size_id :integer(4)
#  campaign_id      :integer(4)
#

class Creative < ActiveRecord::Base
  validates_numericality_of :creative_size_id, :campaign_id
  belongs_to :creative_size
  belongs_to :campaign
end
