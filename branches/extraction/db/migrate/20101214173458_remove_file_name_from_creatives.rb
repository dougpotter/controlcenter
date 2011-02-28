class RemoveFileNameFromCreatives < ActiveRecord::Migration
  def self.up
    remove_column :creatives, :file_name
  end

  def self.down
    add_column :creatives, :file_name, :string
  end
end
