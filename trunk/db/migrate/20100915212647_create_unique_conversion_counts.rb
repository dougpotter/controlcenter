class CreateUniqueConversionCounts < ActiveRecord::Migration
  def self.up
    create_table :unique_conversion_counts do |t|
      t.integer :campaign_id, :null => false
      t.timestamp :start_time, :null => false
      t.timestamp :end_time, :null => false
      t.integer :duration_in_minutes, :null => false
    end

    add_foreign_key :unique_conversion_counts, :campaigns
  end

  def self.down
    remove_foreign_key :unique_conversion_counts, :campaigns

    drop_table :unique_conversion_counts
  end
end
