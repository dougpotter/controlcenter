require "md5"

class AddLineItemIdToCampaigns < ActiveRecord::Migration
  def self.codify_identifier(str, length = 5)
    MD5::md5(str.to_s).to_s[0..(length-1)].upcase
  end
  
  def self.up

    add_column :campaigns, :line_item_id, :integer, :null => false
    
    num_campaigns = connection.select_value(
      "SELECT COUNT(*) FROM campaigns;").to_i
    
    # if campaign table is empty, just add the column (as non-null
    # and a foreign key)
    if num_campaigns > 0
      partner_ids = connection.select_values(
        "SELECT DISTINCT partner_id FROM campaigns;").collect { |id| id.to_i }
      
      partner_ids.each do |partner_id|
        partner_name = connection.select_value(
          "SELECT name FROM partners WHERE " +
          "id = #{quote(partner_id)} LIMIT 1;")
        partner_code = connection.select_value(
          "SELECT partner_code FROM partners WHERE " +
          "id = #{quote(partner_id)} LIMIT 1;")
        default_line_item_code = codify_identifier(partner_code)
        default_line_item_name = "Default Line Item for #{partner_name}"
        
        # Assign all unattached campaigns to a "default" line item
        unless (inserted_row_id = connection.select_value(
          "SELECT id FROM line_items WHERE line_item_code = " + 
          "#{quote(default_line_item_code)} LIMIT 1;"))
          execute("INSERT INTO line_items (line_item_code, name, partner_id) " +
            "VALUES (#{quote(default_line_item_code)}, " + 
            "#{quote(default_line_item_name)}, " + 
            "#{partner_id});")
          inserted_row_id = connection.select_value(
            "SELECT id FROM line_items WHERE line_item_code = " + 
            "#{quote(default_line_item_code)} LIMIT 1;")
        end
        
        execute("UPDATE campaigns SET line_item_id = " + 
          "#{quote(inserted_row_id)} WHERE " +
          "partner_id = #{quote(partner_id)};")
      end
    end

    add_foreign_key :campaigns, :line_items

  end

  def self.down
    remove_foreign_key :campaigns, :line_items
    remove_column :campaigns, :line_item_id
  end
end
