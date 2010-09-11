class CreateInsertionOrders < ActiveRecord::Migration
  def self.up
    create_table :insertion_orders do |t|
      t.text :description
      t.integer :campaign_id
    end
  end

  def self.down
    drop_table :insertion_orders
  end
end
