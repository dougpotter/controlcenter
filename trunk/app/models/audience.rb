# == Schema Information
# Schema version: 20100729211736
#
# Table name: audiences
#
#  id                 :integer(4)      not null, primary key
#  description        :text
#  internal_external  :text
#  seed_extraction_id :integer(4)
#  model_id           :integer(4)
#

class Audience < ActiveRecord::Base
  belongs_to :model
  belongs_to :seed_extraction
  has_and_belongs_to_many :campaigns

  validates_numericality_of :seed_extraction_id, :model_id
end
