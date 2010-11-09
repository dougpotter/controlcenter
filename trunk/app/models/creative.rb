# == Schema Information
# Schema version: 20100819181021
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
  has_many :click_counts
  has_many :impression_counts
  has_and_belongs_to_many :campaigns
  
  validates_presence_of :creative_code, :creative_size_id
  validates_uniqueness_of :creative_code
  validates_numericality_of :creative_size_id

  acts_as_dimension
  business_index :creative_code, :aka => "crid"
  
  def creative_code_and_name
    if description == ""
      creative_code
    else
      "#{creative_code} - #{description}"
    end
  end
end
