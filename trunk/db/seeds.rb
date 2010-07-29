# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

unless clearspring = DataProvider.find_by_name('Clearspring')
  clearspring = DataProvider.create!(:name => 'Clearspring')
end

channel_names = %w(view-us share-us search-hashed-us view-int share-int search-hashed-int)
channel_names.each do |channel_name|
  unless channel = clearspring.data_provider_channels.find_by_name(channel_name)
    channel = DataProviderChannel.create!(:name => channel_name, :data_provider => clearspring)
  end
end
