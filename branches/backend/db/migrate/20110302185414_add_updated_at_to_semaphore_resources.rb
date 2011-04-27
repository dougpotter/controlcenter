class AddUpdatedAtToSemaphoreResources < ActiveRecord::Migration
  def self.up
    add_column :semaphore_resources, :updated_at, :datetime, :null => true
    execute 'update semaphore_resources set updated_at=now()'
    change_column :semaphore_resources, :updated_at, :datetime, :null => false
  end

  def self.down
    remove_column :semaphore_resources, :updated_at
  end
end
