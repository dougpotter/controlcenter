class AddCreativeCodeAsUniqueIndexOnCreatives < ActiveRecord::Migration
  def self.up
    add_index :creatives, :creative_code, :unique => true
  end

  def self.down
    remove_index :creatives, :creative_code
  end
end
