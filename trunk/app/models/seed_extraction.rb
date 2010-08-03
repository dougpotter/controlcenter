# == Schema Information
# Schema version: 20100803143344
#
# Table name: seed_extractions
#
#  id          :integer(4)      not null, primary key
#  description :text
#  mapper      :text
#  reducer     :text
#

# Seed Extraction is defined as an algorithm by which we arrive at a
# seed audience
class SeedExtraction < ActiveRecord::Base
  has_many :audiences
end
