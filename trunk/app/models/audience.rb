# == Schema Information
# Schema version: 20100819181021
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

  validates_presence_of :audience_code
  validates_uniqueness_of :audience_code

  acts_as_dimension
  business_index :audience_code, :aka => "aid"

  def audience_code_and_description
    "#{audience_code} - #{description}"
  end

  class << self
    def generate_audience_code
      CodeGenerator.generate_unique_code(
        self,
        :audience_code,
        :length => 4,
        :alphabet => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
      )   
    end 
  end
end
