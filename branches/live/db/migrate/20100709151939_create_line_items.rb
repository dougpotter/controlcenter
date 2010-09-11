class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.integer :impressions
      t.float :internal_pricing
      t.float :external_pricing
      t.integer :insertion_order_id
   end
  end

  def self.down
    drop_table :line_items
  end
end
