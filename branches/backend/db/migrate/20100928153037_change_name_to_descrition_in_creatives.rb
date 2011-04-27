class ChangeNameToDescritionInCreatives < ActiveRecord::Migration
  def self.up
    rename_column :creatives, :name, :description
  end

  def self.down
    rename_column :creatives, :description, :name
  end
end
