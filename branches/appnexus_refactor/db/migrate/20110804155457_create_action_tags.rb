class CreateActionTags < ActiveRecord::Migration
  def self.up
    create_table :action_tags do |t|
      t.string :name, :null => false
      t.integer :sid, :null => false
      t.string :url, :null => false
      t.integer :partner_id, :null => false
    end

    add_foreign_key :action_tags, :partners
  end

  def self.down
    drop_table :action_tags
  end
end
