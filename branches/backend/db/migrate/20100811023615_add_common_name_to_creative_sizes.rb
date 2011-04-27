class AddCommonNameToCreativeSizes < ActiveRecord::Migration
  def self.up
    add_column :creative_sizes, :common_name, :string
  end

  def self.down
    remove_column :creative_sizes, :common_name
  end
end
