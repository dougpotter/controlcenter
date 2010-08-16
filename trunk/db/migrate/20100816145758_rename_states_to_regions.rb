class RenameStatesToRegions < ActiveRecord::Migration
  def self.up
    rename_table :states, :regions
  end

  def self.down
    rename_table :regions, :states
  end
end
