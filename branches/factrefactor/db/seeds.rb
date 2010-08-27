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

channel_properties = {
  'view-us' => 'hourly',
  'share-us' => 'daily',
  'search-hashed-us' => 'daily',
  'view-int' => 'hourly',
  'share-int' => 'daily',
  'search-hashed-int' => 'daily',
}
channel_properties.each do |channel_name, update_frequency|
  unless channel = clearspring.data_provider_channels.find_by_name(channel_name)
    update_frequency = DataProviderChannel.const_get("UPDATES_#{update_frequency.upcase}")
    channel = DataProviderChannel.create!(
      :name => channel_name,
      :data_provider => clearspring,
      :update_frequency => update_frequency
    )
  end
end
