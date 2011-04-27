class AddIndexOnSemaphoreNameAndLocation < ActiveRecord::Migration
  def self.up
    # name is required for acquisition/release; location is optional.
    # resources are not currently restricted by location only.
    add_index :semaphore_resources, [:name, :location]
  end

  def self.down
    remove_index :semaphore_resources, [:name, :location]
  end
end
