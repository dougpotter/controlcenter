class AddFileNameToCreatives < ActiveRecord::Migration
  def self.up
    add_column :creatives, :file_name, :string
  end

  def self.down
    remove_column :creatives, :file_name
  end
end
