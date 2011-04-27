class ChangeDescriptionToNameInCreativesTable < ActiveRecord::Migration
  def self.up
    rename_column :creatives, :description, :name
  end

  def self.down
    rename_column :creatives, :name, :description
  end
end
