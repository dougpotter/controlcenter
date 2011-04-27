class RefactorTimeWindowsToStartTimeEndTimeDuration < ActiveRecord::Migration
  def self.up
    remove_foreign_key :impression_counts, :time_windows
    remove_foreign_key :click_counts, :time_windows
    remove_foreign_key :remote_placements, :time_windows
    drop_table :time_windows


    remove_column :impression_counts, :time_window_id
    remove_column :click_counts, :time_window_id
    remove_column :remote_placements, :time_window_id
    add_column :impression_counts, :start_time, :timestamp
    add_column :impression_counts, :end_time, :timestamp
    add_column :impression_counts, :duration_in_minutes, :integer
    add_column :click_counts, :start_time, :timestamp
    add_column :click_counts, :end_time, :timestamp
    add_column :click_counts, :duration_in_minutes, :integer
    add_column :remote_placements, :start_time, :timestamp
    add_column :remote_placements, :end_time, :timestamp
    add_column :remote_placements, :duration_in_minutes, :integer
  end

  def self.down
    remove_column :impression_counts, :start_time
    remove_column :impression_counts, :end_time
    remove_column :impression_counts, :duration_in_minutes
    remove_column :click_counts, :start_time
    remove_column :click_counts, :end_time
    remove_column :click_counts, :duration_in_minutes
    remove_column :remote_placements, :start_time
    remove_column :remote_placements, :end_time
    remove_column :remote_placements, :duration_in_minutes

    add_column :impression_counts, :time_window_id, :integer
    add_column :click_counts, :time_window_id, :integer
    add_column :remote_placements, :time_window_id, :integer
    create_table :time_windows do |t|
      t.timestamp :window_begin
      t.timestamp :window_end
    end
    add_foreign_key :impression_counts, :time_windows
    add_foreign_key :click_counts, :time_windows
    add_foreign_key :remote_placements, :time_windows
  end
end
