class CreateMsas < ActiveRecord::Migration
  def self.up
    create_table :msas do |t|
      t.text :country
      t.text :region
    end
  end

  def self.down
    drop_table :msas
  end
end
