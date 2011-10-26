class AddAttributesOnInitializeToClickCounts < ActiveRecord::Migration
  def self.up
    add_column :click_counts, :attributes_on_initialize, :string, :null => false
  end

  def self.down
    remove_column :click_counts, :attributes_on_initialize
  end
end
