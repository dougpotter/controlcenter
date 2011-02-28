class CreateAudiences < ActiveRecord::Migration
  def self.up
    create_table :audiences do |t|
      t.text :description
      t.text :internal_external
      t.integer :seed_extraction_id
      t.integer :model_id
    end
    #add_index :audiences, [:seed_extraction_id, :model_id]
  end

  def self.down
    drop_table :audiences
  end
end
