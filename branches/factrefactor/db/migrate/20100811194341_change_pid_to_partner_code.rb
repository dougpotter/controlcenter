class ChangePidToPartnerCode < ActiveRecord::Migration
  def self.up
    rename_column :partners, :pid, :partner_code
  end

  def self.down
    rename_column :partners, :partner_code, :pid
  end
end
