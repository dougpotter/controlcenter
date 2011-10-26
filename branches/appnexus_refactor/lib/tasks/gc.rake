namespace :gc do
  # Order is important here.
  task :semaphores => %w(
    gc:semaphore:allocations
    gc:semaphore:resources
  )
  
  namespace :semaphore do
    task :resources => :environment do
      cutoff = Time.now - 4.weeks
      Semaphore::Resource.delete_all([
        'not exists (select 1 from semaphore_allocations
        where semaphore_resource_id=semaphore_resources.id)
        and updated_at < ?', cutoff
      ])
    end
    
    task :allocations => :environment do
      cutoff = Time.now - 4.weeks
      Semaphore::Allocation.delete_all([
        'created_at < ? and expires_at < ?', cutoff, cutoff
      ])
    end
  end
end
