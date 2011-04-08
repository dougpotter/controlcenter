class AddPartnerIdToCreatives < ActiveRecord::Migration
  def self.up
    add_column :creatives, :partner_id, :integer

    creative_ids = connection.select_values("SELECT id FROM creatives").
      collect { |id| id.to_i }

    unclassified_partner_id = connection.
      select_value("SELECT id FROM partners WHERE name = 'Unclassified Partner'").
      to_i

    for creative_id in creative_ids
      partner_id = connection.select_value(
        "SELECT line_items.partner_id " +
        "FROM creatives " +
        "join campaigns_creatives on creatives.id = campaigns_creatives.creative_id " +
        "join campaigns on campaigns.id = campaigns_creatives.campaign_id " +
        "join line_items on campaigns.line_item_id = line_items.id " +
        "where creatives.id = #{creative_id}"
      )

      if partner_id
        execute("UPDATE creatives SET partner_id = #{partner_id} " +
          "WHERE id = #{creative_id}")
      else
        execute("UPDATE creatives SET partner_id = #{unclassified_partner_id} " +
          "WHERE id = #{creative_id}")
      end
    end

    add_foreign_key :creatives, :partners
    change_column :creatives, :partner_id, :integer, :null => false
  end

  def self.down
    remove_foreign_key :creatives, :partners
    remove_column :creatives, :partner_id
  end
end
