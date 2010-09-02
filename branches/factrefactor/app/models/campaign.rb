# == Schema Information
# Schema version: 20100819181021
#
# Table name: campaigns
#
#  id            :integer(4)      not null, primary key
#  description   :string(255)     default(""), not null
#  campaign_code :string(255)     default(""), not null
#  partner_id    :integer(4)
#  start_time    :datetime
#  end_time      :datetime
#

# Campaign is defined as a logical grouping of the elements involved
# in providing our advertising service to a client for a pre-defined
# time period.
class Campaign < ActiveRecord::Base
  has_and_belongs_to_many :geographies
  has_and_belongs_to_many :ad_inventory_sources
  has_and_belongs_to_many :creatives
  belongs_to :partner
  belongs_to :insertion_order

  has_many :click_counts
  has_many :impression_counts

  validates_presence_of :description, :campaign_code
  validates_uniqueness_of :campaign_code
  validates_numericality_of :partner_id

  def get_handle
    :campaign_code
  end

  def self.handle_to_id(campaign_code)
    find_by_campaign_code(campaign_code).id
  end

  def self.id_to_handle(id)
    find(id).campaign_code
  end
end