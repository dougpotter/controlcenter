# == Schema Information
# Schema version: 20100816164408
#
# Table name: creatives
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)
#  media_type       :string(255)
#  creative_size_id :integer(4)
#  campaign_id      :integer(4)
#  creative_code    :string(255)     not null
#

# Creative is the visual component of an ad
class Creative < ActiveRecord::Base
  belongs_to :creative_size
  belongs_to :campaign
  has_many :click_counts
  has_many :impression_counts

  validates_numericality_of :creative_size_id, :campaign_id

  def business_code
    :creative_code
  end

  def self.code_to_pk(creative_code)
    find_by_creative_code(creative_code).id
  end
end
