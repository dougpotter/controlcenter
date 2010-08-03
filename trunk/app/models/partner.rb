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

end
