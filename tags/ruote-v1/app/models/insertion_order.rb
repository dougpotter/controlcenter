class InsertionOrder < ActiveRecord::Base
  belongs_to :campaign

  validates_numericality_of :campaign_id
end
