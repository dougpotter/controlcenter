class DropRedundantPartnerIdColumn < ActiveRecord::Migration
  def self.up
    remove_foreign_key :campaigns, :partners
    remove_column :campaigns, :partner_id
  end

  def self.down
    # Need to manually add partner_id column to campaigns, because of lost
    # foreign key constraint
    raise ActiveRecord::IrreversibleMigration
  end
end
