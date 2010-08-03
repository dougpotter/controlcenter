class ChangeTextColsToString < ActiveRecord::Migration
  def self.up
    change_column :ad_inventory_sources, :name, :string
    change_column :audiences, :description, :string
    change_column :audiences, :internal_external, :string
    change_column :campaigns, :description, :string
    change_column :campaigns, :campaign_code, :string
    change_column :creatives, :name, :string
    change_column :creatives, :media_type, :string
    change_column :custom_filters, :description, :string
    change_column :insertion_orders, :description, :string
    change_column :seed_extractions, :description, :string
    change_column :seed_extractions, :mapper, :string
    change_column :seed_extractions, :reducer, :string
  end

  def self.down
    change_column :ad_inventory_sources, :name, :text
    change_column :audiences, :description, :text
    change_column :audiences, :internal_external, :text
    change_column :campaigns, :description, :text
    change_column :campaigns, :campaign_code, :text
    change_column :creatives, :name, :text
    change_column :creatives, :media_type, :text
    change_column :custom_filters, :description, :text
    change_column :insertion_orders, :description, :text
    change_column :seed_extractions, :description, :text
    change_column :seed_extractions, :mapper, :text
    change_column :seed_extractions, :reducer, :text
  end
end
