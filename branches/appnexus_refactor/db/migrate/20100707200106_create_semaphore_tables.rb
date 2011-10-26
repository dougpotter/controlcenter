class CreateSemaphoreTables < ActiveRecord::Migration
  def self.up
    create_table :semaphore_resources do |t|
      t.string :name, :null => false
      t.string :location, :null => true
      t.integer :capacity, :null => false
      t.integer :usage, :null => true
    end
    
    create_table :semaphore_allocations do |t|
      t.integer :semaphore_resource_id, :null => false
      t.datetime :created_at, :null => false
      t.datetime :expires_at, :null => false
      t.integer :pid, :null => true
      t.column :tid, 'bigint', :null => true
      t.string :host, :null => true
      t.integer :state, :null => false
    end
  end

  def self.down
    drop_table :semaphore_allocations
    drop_table :semaphore_resources
  end
end
