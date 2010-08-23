# == Schema Information
# Schema version: 20100819181021
#
# Table name: partner_beacon_requests
#
#  id               :integer(4)      not null, primary key
#  host_ip          :string(255)
#  request_time     :datetime
#  request_url      :string(1023)
#  status_code      :integer(4)
#  referer_url      :string(511)
#  user_agent       :string(511)
#  partner_id       :integer(4)
#  user_agent_class :string(255)
#  xguid            :string(255)
#  xgcid            :string(255)
#  puid             :string(255)
#  pid              :integer(4)
#

require 'spec_helper'

describe PartnerBeaconRequest do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    PartnerBeaconRequest.create!(@valid_attributes)
  end
end
