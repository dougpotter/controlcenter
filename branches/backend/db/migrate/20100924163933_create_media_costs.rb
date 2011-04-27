class CreateMediaCosts < ActiveRecord::Migration
  def self.up
    create_table :media_costs do |t|
      t.integer :partner_id, :null => false
      t.integer :campaign_id, :null => false
      t.integer :media_purchase_method_id, :null => false
      t.integer :audience_id, :null => false
      t.integer :creative_id, :null => false
      t.timestamp :start_time, :null => false
      t.timestamp :end_time, :null => false
      t.integer :duration_in_minutes, :null => false
      t.float :media_cost, :null => false
    end

    add_foreign_key :media_costs, :partners
    add_foreign_key :media_costs, :campaigns
    add_foreign_key :media_costs, :media_purchase_methods
    add_foreign_key :media_costs, :audiences
    add_foreign_key :media_costs, :creatives
  end

  def self.down
    remove_foreign_key :media_costs, :partners
    remove_foreign_key :media_costs, :campaigns
    remove_foreign_key :media_costs, :media_purchase_methods
    remove_foreign_key :media_costs, :audiences
    remove_foreign_key :media_costs, :creatives

    drop_table :media_costs
  end
end
