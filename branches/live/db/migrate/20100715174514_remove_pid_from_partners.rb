class RemovePidFromPartners < ActiveRecord::Migration
  def self.up
    remove_column :partners, :pid
  end

  def self.down
    add_column :partners, :pid, :integer
    add_index :partners, :pid, :unique => true
  end
end
