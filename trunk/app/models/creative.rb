# == Schema Information
# Schema version: 20100803143344
#
# Table name: creatives
#
#  id               :integer(4)      not null, primary key
#  name             :text
#  media_type       :text
#  creative_size_id :integer(4)
#  campaign_id      :integer(4)
#

# Creative is the visual component of an ad
class Creative < ActiveRecord::Base
  belongs_to :creative_size
  belongs_to :campaign
  has_many :click_counts
  has_many :impression_counts

  validates_numericality_of :creative_size_id, :campaign_id
end
