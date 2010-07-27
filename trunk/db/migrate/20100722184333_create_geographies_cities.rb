class CreateGeographiesCities < ActiveRecord::Migration
  def self.up
    create_table :geographies_cities do |t|
      t.integer :city_id
      t.integer :geography_id
    end
  end

  def self.down
    drop_table :geographies_cities
  end
end
