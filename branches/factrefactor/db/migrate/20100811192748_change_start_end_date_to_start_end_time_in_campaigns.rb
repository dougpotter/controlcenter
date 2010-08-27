class ChangeStartEndDateToStartEndTimeInCampaigns < ActiveRecord::Migration
  def self.up
    rename_column :campaigns, :start_date, :start_time
    rename_column :campaigns, :end_date, :end_time
  end

  def self.down
    rename_column :campaigns, :start_time, :start_date
    rename_column :campaigns, :end_time, :end_date
  end
end
