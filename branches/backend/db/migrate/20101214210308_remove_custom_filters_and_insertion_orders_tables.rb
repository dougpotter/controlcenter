class RemoveCustomFiltersAndInsertionOrdersTables < ActiveRecord::Migration
  def self.up
    remove_foreign_key :insertion_orders, :campaigns
    remove_foreign_key :custom_filters_line_items, :line_items
    remove_foreign_key :custom_filters_line_items, :custom_filters

    drop_table :custom_filters_line_items
    drop_table :custom_filters
    drop_table :insertion_orders
  end

  def self.down
    create_table :custom_filters_line_items, { :id => false } do |t| 
      t.integer :custom_filter_id, :null => false
      t.integer :insertion_orders_id, :null => false
      t.integer :line_item_id, :null => false
    end 

    create_table :custom_filters do |t| 
      t.text :description
      t.timestamps
    end

    create_table :insertion_orders do |t| 
      t.text :description
      t.integer :campaign_id
    end

    add_foreign_key :insertion_orders, :campaigns
    add_foreign_key :custom_filters_line_items, :line_items
    add_foreign_key :custom_filters_line_items, :custom_filters
  end
end
