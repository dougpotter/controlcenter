class AddNameDateToDataProviderFiles < ActiveRecord::Migration
  def self.up
    add_column :data_provider_files, :name_date, :date, :null => true
  end

  def self.down
    remove_column :data_provider_files, :name_date
  end
end
