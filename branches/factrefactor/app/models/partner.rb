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

  def get_handle
    :partner_code
  end
  
  def pid ; partner_code ; end

  def self.handle_to_id(partner_code)
    find_by_partner_code(partner_code).id
  end

  def self.id_to_handle(id)
    find(id).partner_code
  end
end
