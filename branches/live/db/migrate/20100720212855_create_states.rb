class CreateStates < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.string :abbreviation, :null => false
    end
  end

  def self.down
    drop_table :states
  end
end
