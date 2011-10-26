class UpdateLineItems < ActiveRecord::Migration
  def self.up
    remove_column :line_items, :impressions
    remove_column :line_items, :internal_pricing
    remove_column :line_items, :external_pricing
    remove_column :line_items, :insertion_order_id

    add_column :line_items, :line_item_code, :string, :null => false
    add_column :line_items, :name, :string, :null => false, :unique => true
    add_column :line_items, :start_time, :timestamp
    add_column :line_items, :end_time, :timestamp
    add_column :line_items, :partner_id, :integer, :null => false

    add_index :line_items, :line_item_code, :unique => true

    add_foreign_key :line_items, :partners
  end

  def self.down
    remove_foreign_key :line_items, :partners

    remove_column :line_items, :line_item_code
    remove_column :line_items, :name
    remove_column :line_items, :start_time
    remove_column :line_items, :end_time
    remove_column :line_items, :partner_id

    add_column :line_items, :impressions, :integer
    add_column :line_items, :internal_pricing, :float
    add_column :line_items, :external_pricing, :float
    add_column :line_items, :insertion_order_id, :integer
  end
end
