class RelaxQuniquenessIndexInAudienceManifests < ActiveRecord::Migration
  def self.up
    # This is to facilitate persisting a record of the progression of an anaudiences
    # sources. Now users will be able to see each of the sources - including 
    # duplicates - in the order in which they were used. 
    remove_foreign_key :audience_manifests, :audiences
    remove_foreign_key :audience_manifests, :audience_sources
    remove_index :audience_manifests, :name => "unique_join_columns"
    add_foreign_key :audience_manifests, :audiences
    add_foreign_key :audience_manifests, :audience_sources
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
