# == Schema Information
# Schema version: 20101220202022
#
# Table name: campaigns
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)     default(""), not null
#  campaign_code :string(255)     default(""), not null
#  start_time    :datetime
#  end_time      :datetime
#  line_item_id  :integer(4)      not null
#

# Campaign is defined as a logical grouping of the elements involved
# in providing our advertising service to a client for a pre-defined
# time period.
class Campaign < ActiveRecord::Base
  has_and_belongs_to_many :geographies
  has_and_belongs_to_many :ad_inventory_sources
  has_and_belongs_to_many :creatives
  has_one :audience
  belongs_to :line_item

  has_many :click_counts
  has_many :impression_counts

  validates_presence_of :name, :campaign_code
  validates_uniqueness_of :campaign_code

  acts_as_dimension
  business_index :campaign_code, :aka => "cid"
  
  def campaign_code_and_description
    out = campaign_code
    out += " - #{name}" unless name.blank?
    out
  end

  class << self
    def generate_campaign_code
      CodeGenerator.generate_unique_code(
        self,
        :campaign_code,
        :length => 4,
        :alphabet => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
      )
    end
  end
end
