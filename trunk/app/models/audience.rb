# == Schema Information
# Schema version: 20100816164408
#
# Table name: audiences
#
#  id            :integer(4)      not null, primary key
#  description   :string(255)
#  audience_code :string(255)     not null
#

# Audience is defined as a list of targetable individuals. It 
# encompasses both 'internal' and 'external' audiences - the 
# former being a group we of users we have identified as desirable
# targets and the latter being those among and internal audience
# who have been cookied.
#
class Audience < ActiveRecord::Base
  belongs_to :model
  belongs_to :seed_extraction
  has_and_belongs_to_many :campaigns

  has_many :click_counts
  has_many :impression_counts

  def business_code
    :audience_code
  end

  def self.code_to_pk(audience_code)
    find_by_audience_code(audience_code).id
  end
end
