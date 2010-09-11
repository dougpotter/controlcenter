class RemoveSuperfluousColumnsFromAudiences < ActiveRecord::Migration
  def self.up
    remove_foreign_key "audiences", "models"
    remove_foreign_key "audiences", "seed_extractions"

    remove_index "audiences", :name => "audiences_model_id_fk"
    remove_index "audiences", :name => "audiences_seed_extraction_id_fk"
    
    remove_column :audiences, :model_id
    remove_column :audiences, :seed_extraction_id
    remove_column :audiences, :internal_external
  end

  def self.down
    add_column :audiences, :internal_external, :string
    add_column :audiences, :seed_extraction_id, :integer, :null => false
    add_column :audiences, :model_id, :integer, :null => false

    add_index "audiences", ["seed_extraction_id"], :name => "audiences_seed_extraction_id_fk"
    add_index "audiences", ["model_id"], :name => "audiences_model_id_fk"

    add_foreign_key "audiences", "seed_extractions", :name => "audiences_seed_extraction_id_fk"
    add_foreign_key "audiences", "models", :name => "audiences_model_id_fk"
  end
end
