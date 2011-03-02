class AddSemaphoreResourceIdIndexToAllocations < ActiveRecord::Migration
  def self.up
    add_index :semaphore_allocations, [:semaphore_resource_id]
    add_foreign_key :semaphore_allocations, :semaphore_resources
  end

  def self.down
    remove_foreign_key :semaphore_allocations, :semaphore_resources
    remove_index :semaphore_allocations, [:semaphore_resources]
  end
end
