class CreateAudienceSources < ActiveRecord::Migration
  def self.up
    create_table :audience_sources do |t|
      t.string :referrer_regex
      t.string :request_regex
      t.string :s3_bucket
      t.string :type
      t.string :load_status
      t.string :beacon_load_id
    end
  end

  def self.down
    drop_table :audience_sources
  end
end
