class AddTimesToDataProviderFiles < ActiveRecord::Migration
  def self.up
    %w(discovered_at extracted_at verified_at).each do |column_name|
      add_column :data_provider_files, column_name, :datetime, :null => true
    end
  end

  def self.down
    %w(discovered_at extracted_at verified_at).each do |column_name|
      remove_column :data_provider_files, column_name
    end
  end
end
