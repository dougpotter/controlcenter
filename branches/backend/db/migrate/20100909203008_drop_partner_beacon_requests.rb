class DropPartnerBeaconRequests < ActiveRecord::Migration
  def self.up
    drop_table :partner_beacon_requests
  end

  def self.down
    create_table :partner_beacon_requests do |t| 
      t.column :host_ip, :string
      t.column :request_time, :datetime
      t.column :request_url, :string, :limit => 1023
      t.column :status_code, :integer
      t.column :referer_url, :string, :limit => 511 
      t.column :user_agent, :string, :limit => 511 
      t.column :pid, :integer
      t.column :user_agent_class, :string
      t.column :xguid, :string
      t.column :xgcid, :string
      t.column :puid, :string
    end
  end
end
