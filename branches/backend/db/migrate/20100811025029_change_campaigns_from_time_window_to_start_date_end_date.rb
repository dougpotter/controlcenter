class ChangeCampaignsFromTimeWindowToStartDateEndDate < ActiveRecord::Migration
  def self.up
    remove_foreign_key "campaigns", "time_windows"
    remove_index :campaigns, :name => "campaigns_time_window_id_fk"
    
    add_column :campaigns, :start_date, :datetime
    add_column :campaigns, :end_date, :datetime
    
    Campaign.find(:all).each do |campaign|
      campaign.start_date = 
          TimeWindow.find_by_id(campaign.time_window_id).window_begin.to_date
      campaign.end_date = 
          TimeWindow.find_by_id(campaign.time_window_id).window_end.to_date
      campaign.save!
    end
    
    remove_column :campaigns, :time_window_id
  end

  def self.down
    add_column :campaigns, :time_window_id, :integer, :null => false
    
    Campaign.find(:all).each do |campaign|
      if (t = TimeWindow.find_by_window_begin_and_window_end(
          campaign.start_date, campaign.end_date))
        campaign.time_window_id = t.id
      else
        # Raising error might be too aggressive; if you hit it, try
        # just outputtting all troublesome campaigns to stderr
        # (You'll also have to DROP COLUMN time_window_id)
        raise "Could not find time window for campaign ID=#{campaign.id}"
      end
    end
    
    remove_column :campaigns, :end_date
    remove_column :campaigns, :start_date
    
    add_foreign_key "campaigns", "time_windows", :name => "campaigns_time_window_id_fk"
    add_index "campaigns", ["time_window_id"], :name => "campaigns_time_window_id_fk"
  end
end
