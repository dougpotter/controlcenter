class Partner < ActiveRecord::Base
  validates_uniqueness_of :pid
  validates_numericality_of :pid
  
  has_many :partner_beacon_requests, {
    :primary_key => "pid",
    :foreign_key => "pid"
  }
  
end
