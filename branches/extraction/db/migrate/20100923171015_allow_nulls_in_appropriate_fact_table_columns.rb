class AllowNullsInAppropriateFactTableColumns < ActiveRecord::Migration
  def self.up
    change_column :unique_conversion_counts, :campaign_id, :integer, :null => true
  end

  def self.down
    change_column :unique_conversion_counts, :campaign_id, :integer, :null => false
  end
end
