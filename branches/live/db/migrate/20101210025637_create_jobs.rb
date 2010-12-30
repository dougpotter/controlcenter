class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :type, :null => false
      # parameters are not very readable.
      # name may be programmatically assigned but should be readable.
      # note that name is not required to be unique -
      # something like daily jobs could have identical names, and be
      # distinguished by start time, while more frequent jobs
      # should perhaps incorporate more than just type in the name.
      t.string :name, :null => false
      # hash of parameters, serialized to yaml
      t.text :parameters, :null => false
      t.datetime :created_at, :null => false
      # created, processing, complete
      t.integer :status, :null => false
      # information needed to check job status goes into state
      t.text :state, :null => false
      t.datetime :completed_at, :null => true
    end
  end

  def self.down
    drop_table :job_infos
  end
end
