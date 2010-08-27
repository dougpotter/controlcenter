class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.column :name, :string
      t.column :pid, :integer
    end
    
    add_index :partners, :pid, :unique => true
  end

  def self.down
    drop_table :partners
  end
end
