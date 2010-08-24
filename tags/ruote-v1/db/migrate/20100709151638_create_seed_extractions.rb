class CreateSeedExtractions < ActiveRecord::Migration
  def self.up
    create_table :seed_extractions do |t|
      t.text :description
      t.text :mapper
      t.text :reducer
    end
  end

  def self.down
    drop_table :seed_extractions
  end
end
