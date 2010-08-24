class PartnerBeaconRequest < ActiveRecord::Base
  belongs_to :partner, {
    :primary_key => "pid",
    :foreign_key => "pid"
  }
end
