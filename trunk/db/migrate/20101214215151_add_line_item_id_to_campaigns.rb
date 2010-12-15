class AddLineItemIdToCampaigns < ActiveRecord::Migration
  def self.up
    # if line item and campaign tables are empty, just add the column (as non-null
    # and a foreign key)
    if LineItem.all == [] && Campaign.all == []
      add_column :campaigns, :line_item_id, :integer, :null => false
      add_foreign_key :campaigns, :line_items
    
    # if not, add an unknown partner and unknown line item and assign all existing
    # campaigns to those two (to be properly classified later) 
    else 
      Partner.create({:name => "Unclassified Partner", :partner_code => 9999999})
      LineItem.create({ :line_item_code => 9999999, :name => "Unclassified Line Item", :partner_id => Partner.find(:first, :conditions => { :partner_code => 9999999 }).id }) 
      add_column :campaigns, :line_item_id, :integer, :null => false, :default => LineItem.find(:first, :conditions => { :line_item_code => 9999999 })
      add_foreign_key :campaigns, :line_items
    end


  end

  def self.down
    remove_foreign_key :campaigns, :line_items
    remove_column :campaigns, :line_item_id
  end
end
