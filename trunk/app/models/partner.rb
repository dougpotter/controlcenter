class Partner < ActiveRecord::Base
  has_many :partner_beacon_requests
  has_many :campaigns
  
end
