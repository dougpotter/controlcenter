class AddDateAndHoursToDataProviderFiles < ActiveRecord::Migration
  def self.up
    # See the comment in data provider file model about these fields.
    add_column :data_provider_files, :label_date, :date
    add_column :data_provider_files, :label_hour, :integer
    
    # First version of the fields - they reflect content accurately
    # but most importantly fail to properly group files by date as
    # included in file names.
    #add_column :data_provider_files, :range_from, :datetime
    #add_column :data_provider_files, :range_to, :datetime
  end

  def self.down
    remove_column :data_provider_files, :label_date
    remove_column :data_provider_files, :label_hour
    
    #remove_column :data_provider_files, :range_from
    #remove_column :data_provider_files, :range_to
  end
end
