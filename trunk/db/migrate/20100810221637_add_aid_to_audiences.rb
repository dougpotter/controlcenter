class AddAidToAudiences < ActiveRecord::Migration
  def self.up
    add_column :audiences, :aid, :integer, :null => false
  end

  def self.down
    remove_column :audiences, :aid
  end
end
