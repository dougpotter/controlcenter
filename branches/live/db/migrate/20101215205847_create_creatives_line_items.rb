class CreateCreativesLineItems < ActiveRecord::Migration
  def self.up
    create_table :creatives_line_items, { :id => false } do |t|
      t.integer :creative_id, :null => false
      t.integer :line_item_id, :null => false
    end

    add_foreign_key :creatives_line_items, :creatives
    add_foreign_key :creatives_line_items, :line_items
  end

  def self.down
    remove_foreign_key :creatives_line_items, :creatives
    remove_foreign_key :creatives_line_items, :line_items

    drop_table :creatives_line_items
  end
end
