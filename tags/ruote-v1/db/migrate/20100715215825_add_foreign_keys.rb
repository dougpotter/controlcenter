class AddForeignKeys < ActiveRecord::Migration
  def self.up
    add_foreign_key(:creatives, :campaigns)
    add_foreign_key(:creatives, :creative_sizes)
    add_foreign_key(:campaigns, :partners)
    add_foreign_key(:insertion_orders, :campaigns)
    add_foreign_key(:audiences, :seed_extractions)
    add_foreign_key(:audiences, :models)

    add_foreign_key(:campaigns_msas, :campaigns)
    add_foreign_key(:campaigns_msas, :msas)
    add_foreign_key(:ad_inventory_sources_campaigns, :campaigns)
    add_foreign_key(:ad_inventory_sources_campaigns, :ad_inventory_sources)
    add_foreign_key(:audiences_campaigns, :audiences)
    add_foreign_key(:audiences_campaigns, :campaigns)
    add_foreign_key(:custom_filters_line_items, :line_items)
    add_foreign_key(:custom_filters_line_items, :custom_filters)
  end

  def self.down
    remove_foreign_key(:creatives, :campaigns)
    remove_foreign_key(:creatives, :creative_sizes)
    remove_foreign_key(:campaigns, :partners)
    remove_foreign_key(:insertion_orders, :campaigns)
    remove_foreign_key(:audiences, :seed_extractions)
    remove_foreign_key(:audiences, :models)
    remove_foreign_key(:campaigns_msas, :campaigns)
    remove_foreign_key(:campaigns_msas, :msas)
    remove_foreign_key(:ad_inventory_sources_campaigns, :campaigns)
    remove_foreign_key(:ad_inventory_sources_campaigns, :ad_inventory_sources)
    remove_foreign_key(:audiences_campaigns, :audiences)
    remove_foreign_key(:audiences_campaigns, :campaigns)
    remove_foreign_key(:custom_filters_line_items, :line_items)
    remove_foreign_key(:custom_filters_line_items, :custom_filters)
  end
end
