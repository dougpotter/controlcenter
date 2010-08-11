# == Schema Information
# Schema version: 20100803143344
#
# Table name: partners
#
#  id   :integer(4)      not null, primary key
#  name :string(255)
#

# Partner is defined as a client on whose behalf we execute Campaigns
class Partner < ActiveRecord::Base
  has_many :partner_beacon_requests
  has_many :campaigns

  validates_uniqueness_of :partner_code

  def business_code
    :partner_code
  end

  def self.code_to_pk(partner_code)
    find_by_partner_code(partner_code).id
  end
end
