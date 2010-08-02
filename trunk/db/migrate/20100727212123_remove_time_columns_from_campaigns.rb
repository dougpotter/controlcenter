class RemoveTimeColumnsFromCampaigns < ActiveRecord::Migration
  def self.up
    remove_column :campaigns, :start_date
    remove_column :campaigns, :end_date
  end

  def self.down
    add_column :campaigns, :start_date, :date
    add_column :campaigns, :end_date, :date
  end
end
