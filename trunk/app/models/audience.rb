class Audience < ActiveRecord::Base
  belongs_to :model
  belongs_to :seed_extraction
  has_and_belongs_to_many :campaigns

  validates_numericality_of :seed_extraction_id, :model_id
end
