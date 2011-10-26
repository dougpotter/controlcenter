class AddForeignKeyConstraintsToAudienceManifests < ActiveRecord::Migration
  def self.up
    # de-dup 
    ams = AudienceManifest.all(
      :order => "audience_manifests.audience_id, audience_manifests.audience_source_id")
    for i in 1...ams.size
      if ams[i].audience_id == ams[i - 1].audience_id &&
        ams[i].audience_source_id == ams[i - 1].audience_source_id
        ams[i].delete
      end
    end

    # add fk constraints
    add_foreign_key :audience_manifests, :audiences
    add_foreign_key :audience_manifests, :audience_sources
  end

  def self.down
    remove_foreign_key :audience_manifests, :audiences
    remove_foreign_key :audience_manifests, :audience_sources
  end
end
