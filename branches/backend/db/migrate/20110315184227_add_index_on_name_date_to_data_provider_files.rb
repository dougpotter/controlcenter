class AddIndexOnNameDateToDataProviderFiles < ActiveRecord::Migration
  def self.up
    add_index :data_provider_files, :name_date
  end

  def self.down
    remove_index :data_provider_files, :name_date
  end
end
