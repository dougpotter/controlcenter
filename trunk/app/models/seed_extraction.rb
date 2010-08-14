# == Schema Information
# Schema version: 20100813163534
#
# Table name: seed_extractions
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  mapper      :string(255)
#  reducer     :string(255)
#

# Seed Extraction is defined as an algorithm by which we arrive at a
# seed audience
class SeedExtraction < ActiveRecord::Base
  has_many :audiences
end
