class CustomFiltersLineItems < ActiveRecord::Migration
  def self.up
    create_table :custom_filters_line_items, { :id => false } do |t|
      t.integer :custom_filter_id, :null => false
      # not sure if ruby supports compound primary keys???
      t.integer :insertion_orders_id, :null => false
      t.integer :line_item_id, :null => false
    end
    #add_index :customer_filters_line_items, [:custom_filter_id, :insertion_orders_id, :line_item_id], :unique => true
  end

  def self.down
    drop_table :custom_filters_line_items
  end
end
