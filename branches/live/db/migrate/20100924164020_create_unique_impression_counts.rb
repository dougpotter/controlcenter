class CreateUniqueImpressionCounts < ActiveRecord::Migration
  def self.up
    create_table :unique_impression_counts do |t| 
      t.integer :partner_id
      t.integer :campaign_id
      t.integer :media_purchase_method_id
      t.integer :audience_id
      t.integer :creative_id
      t.timestamp :start_time, :null => false
      t.timestamp :end_time, :null => false
      t.integer :duration_in_minutes, :null => false
      t.integer :unique_impression_count, :null => false
    end 

    add_foreign_key :unique_impression_counts, :partners
    add_foreign_key :unique_impression_counts, :campaigns
    add_foreign_key :unique_impression_counts, :media_purchase_methods
    add_foreign_key :unique_impression_counts, :audiences
    add_foreign_key :unique_impression_counts, :creatives
  end 

  def self.down
    remove_foreign_key :unique_impression_counts, :partners
    remove_foreign_key :unique_impression_counts, :campaigns
    remove_foreign_key :unique_impression_counts, :media_purchase_methods
    remove_foreign_key :unique_impression_counts, :audiences
    remove_foreign_key :unique_impression_counts, :creatives

    drop_table :unique_impression_counts
  end
end
