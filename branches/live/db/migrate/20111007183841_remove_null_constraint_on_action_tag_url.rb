class RemoveNullConstraintOnActionTagUrl < ActiveRecord::Migration
  def self.up
    change_column :action_tags, :url, :string, :null => true
  end

  def self.down
    change_column :action_tags, :url, :string, :null => false
  end
end
