class Creative < ActiveRecord::Base
  validates_numericality_of :creative_size_id, :campaign_id
	belongs_to :creative_size
	belongs_to :campaign
end
