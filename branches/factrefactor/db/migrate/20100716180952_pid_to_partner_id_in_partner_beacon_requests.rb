class PidToPartnerIdInPartnerBeaconRequests < ActiveRecord::Migration
  def self.up
    rename_column :partner_beacon_requests, :pid, :partner_id
  end

  def self.down
    rename_column :partner_beacon_requests, :partner_id, :pid
  end
end
