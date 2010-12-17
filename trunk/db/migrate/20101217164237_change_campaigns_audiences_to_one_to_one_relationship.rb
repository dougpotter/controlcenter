class ChangeCampaignsAudiencesToOneToOneRelationship < ActiveRecord::Migration

  # This migration adds a campaign_id column to the partners table and assignes
  # all current audiences to thier 'first' (in active record terms) campaign
  # to which they are already associated. If they are not associated with any
  # campaigns, they are assigned to the campaing named "Unassigned" (which I 
  # also create here). I drop the many-to-many join table audiences_campaigns
  # in the next migration.
  
  def self.up
    add_column :audiences, :campaign_id, :integer

    Partner.create({:name => "Unclassified Partner", :partner_code => 9999999})
    LineItem.create({ :line_item_code => 9999999, :name => "Unclassified Line Item", :partner_id => Partner.find(:first, :conditions => { :partner_code => 9999999 }).id })

    c = Campaign.create({
      :name => "Unassigned",
      :campaign_code => "9999999",
      :partner_id => Partner.find(:first, :conditions => {:partner_code => "9999999" }).id,
      :line_item_id => LineItem.find(:first, :conditions => {:line_item_code => "9999999" }).id
    })

    if !c.save
      remove_column :audiences, :campaign_id
      exit
    end

    for audience in Audience.all
      if audience.campaigns != []
        audience.campaign_id = audience.campaigns.first.id.to_i
      else
        audience.campaign_id = c.id
      end
      audience.save!
    end

    add_foreign_key :audiences, :campaigns

  end

  def self.down
    remove_foreign_key :audiences, :campaigns
    remove_column :audiences, :campaign_id
    c = Campaign.find(:first, :conditions => { :campaign_code => 9999999 })
    c.delete
  end
end
