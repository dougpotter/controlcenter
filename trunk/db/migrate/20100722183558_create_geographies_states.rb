class CreateGeographiesStates < ActiveRecord::Migration
  def self.up
    create_table :geographies_states do |t|
      t.integer :state_id
      t.integer :geography_id
    end
  end

  def self.down
    drop_table :geographies_states
  end
end
