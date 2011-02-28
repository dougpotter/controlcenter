class AddTimeWindowToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :time_window_id, :integer
    add_foreign_key :campaigns, :time_windows
  end

  def self.down
    remove_foreign_key :campaigns, :time_windows
    remove_column :campaigns, :time_window_id
  end
end
