class AddRelationshipsForMediaPurchaseMethods < ActiveRecord::Migration
  def self.up
    add_column :click_counts, :media_purchase_method_id, :integer
    add_column :impression_counts, :media_purchase_method_id, :integer
    
    add_foreign_key :click_counts, :media_purchase_methods
    add_foreign_key :impression_counts, :media_purchase_methods
  end

  def self.down
    remove_foreign_key :impression_counts, :media_purchase_methods
    remove_foreign_key :click_counts, :media_purchase_methods
    
    remove_column :impression_counts, :media_purchase_method_id
    remove_column :click_counts, :media_purchase_method_id  
  end
end
