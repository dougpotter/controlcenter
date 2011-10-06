class AddBeaconIdToAudiences < ActiveRecord::Migration
  def self.up
    add_column :audiences, :beacon_id, :integer
  end

  def self.down
    remove_column :audiences, :beacon_id
  end
end
