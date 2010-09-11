class RenameColumnsGeographies < ActiveRecord::Migration
  def self.up
    remove_column :geographies, :country
    remove_column :geographies, :region
    add_column :geographies, :description, :string
    change_column :geographies, :id, :integer
  end

  def self.down
    remove_column :geographies, :description
    add_column :geographies, :country, :string
    add_column :geographies, :region, :string
  end
end
