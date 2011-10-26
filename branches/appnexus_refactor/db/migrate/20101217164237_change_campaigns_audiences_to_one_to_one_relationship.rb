class ChangeCampaignsAudiencesToOneToOneRelationship < ActiveRecord::Migration

  # This migration adds a campaign_id column to the partners table and attempts
  # to set the campaign_id of each audience to the campaign tied to that
  # audience in the current many-many audiences_campaigns table, if EXACTLY
  # ONE such campaign exists.
  #
  # If any audience is attached to 0, or more than one, campaign (i.e., not 
  # EXACTLY ONE campaign), an exception will be raised forcing user
  # intervention.
  
  
  def self.up
    # Raise exception and force user reconciliation if multiple campaigns are
    # tied to any audience.
    
    audience_ids = select_values(
      "SELECT DISTINCT id FROM audiences;").collect { |id| id.to_i }
    
    audience_ids.each do |audience_id|
      num_campaigns = select_value(
        "SELECT COUNT(*) FROM audiences_campaigns " +
        "WHERE audience_id = #{quote(audience_id)};").to_i
      
      unless num_campaigns == 1
        raise "Audience ID=#{audience_id} has #{num_campaigns} campaigns " +
          "(1 expected). Please reconcile audiences_campaigns table."
      end
    end
    
    # Create campaign_id with uniqueness constraint to enforce "has_one"
    # relationship
    add_column :audiences, :campaign_id, :integer
    add_index :audiences, :campaign_id, :unique => true

    audience_ids.each do |audience_id|
      campaign_id = select_value(
        "SELECT campaign_id FROM audiences_campaigns " +
        "WHERE audience_id = #{quote(audience_id)} LIMIT 1;").to_i
      execute("UPDATE audiences SET campaign_id = #{quote(campaign_id)} " + 
        "WHERE id = #{quote(audience_id)}")
    end
    
    add_foreign_key :audiences, :campaigns

  end

  def self.down
    remove_foreign_key :audiences, :campaigns
    
    remove_index :audiences, :column => :campaign_id
    remove_column :audiences, :campaign_id
  end
end
