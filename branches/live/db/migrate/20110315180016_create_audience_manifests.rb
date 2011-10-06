class CreateAudienceManifests < ActiveRecord::Migration
  def self.up
    create_table :audience_manifests do |t|
      t.integer :audience_id, :null => false
      t.integer :audience_source_id, :null => false
      t.integer :audience_iteration_number, :null => false
    end

    add_index :audience_manifests, 
      [ :audience_id, :audience_source_id ], 
      { :unique => true, :name => "unique_join_columns" }
  end

  def self.down
    remove_index :audience_manifests, :name => "unique_join_columns"
    drop_table :audience_manifests
  end
end
