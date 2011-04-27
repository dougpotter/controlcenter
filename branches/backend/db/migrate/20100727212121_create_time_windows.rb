class CreateTimeWindows < ActiveRecord::Migration
  def self.up
    create_table :time_windows do |t|
      t.datetime :window_begin, :null => true
      t.datetime :window_end, :null => true
    end
  end

  def self.down
    drop_table :time_windows
  end
end
