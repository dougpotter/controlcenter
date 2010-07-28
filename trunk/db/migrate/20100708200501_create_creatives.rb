class CreateCreatives < ActiveRecord::Migration
  def self.up
    create_table :creatives do |t|
      t.text :name
      t.text :media_type
      t.integer :creative_size_id
      t.integer :campaign_id
    end
    #add_index :creatives, [:creative_size_id, :campaign_id], :unique => true
  end

  def self.down
    drop_table :creatives
  end
end
