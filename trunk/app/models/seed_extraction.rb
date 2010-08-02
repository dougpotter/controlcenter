# == Schema Information
# Schema version: 20100729211736
#
# Table name: seed_extractions
#
#  id          :integer(4)      not null, primary key
#  description :text
#  mapper      :text
#  reducer     :text
#

class SeedExtraction < ActiveRecord::Base
  has_many :audiences
end
