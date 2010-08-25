class AddNotNullContraintsToCreatives < ActiveRecord::Migration
  def self.up
    change_column :creatives, :creative_size_id, :integer, :null => false
    change_column :creatives, :campaign_id, :integer, :null => false
  end

  def self.down
    change_column :creatives, :creative_size_id, :integer, :null => true
    change_column :creatives, :campaign_id, :integer, :null => true
  end
end
