# == Schema Information
# Schema version: 20100819181021
#
# Table name: partners
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)
#  partner_code :integer(4)      not null
#

# Partner is defined as a client on whose behalf we execute Campaigns
class Partner < ActiveRecord::Base
  has_many :partner_beacon_requests
  has_many :campaigns

  validates_uniqueness_of :partner_code
  def pid ; partner_code ; end

  acts_as_dimension
  business_index :partner_code, :aka => "pid"
end
