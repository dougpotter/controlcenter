class CreateCustomFilters < ActiveRecord::Migration
  def self.up
    create_table :custom_filters do |t|
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :custom_filters
  end
end
