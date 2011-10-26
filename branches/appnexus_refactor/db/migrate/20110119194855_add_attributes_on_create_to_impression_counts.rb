class AddAttributesOnCreateToImpressionCounts < ActiveRecord::Migration
  def self.up
    add_column :impression_counts, :attributes_on_initialize, :string, :null => false
  end

  def self.down
    remove_column :impression_counts, :attributes_on_initialize
  end
end
