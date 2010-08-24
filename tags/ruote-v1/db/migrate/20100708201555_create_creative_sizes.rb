class CreateCreativeSizes < ActiveRecord::Migration
  def self.up
    create_table :creative_sizes do |t|
      t.float :height
      t.float :width

      t.timestamps
    end
  end

  def self.down
    drop_table :creative_sizes
  end
end
