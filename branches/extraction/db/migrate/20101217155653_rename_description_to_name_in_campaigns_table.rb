class RenameDescriptionToNameInCampaignsTable < ActiveRecord::Migration
  def self.up
    rename_column :campaigns, :description, :name
  end

  def self.down
    rename_column :campaigns, :name, :description
  end
end
