class RemoveTimestampCreativeSizes < ActiveRecord::Migration
  def self.up
    remove_columns :creative_sizes, :created_at, :updated_at
  end

  def self.down
    change_table :creative_sizes do |t|
      t.timestamps
    end
  end
end
