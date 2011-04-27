require 'spec_helper'

describe Semaphore::Arbitrator do
  before :each do
    @arbitrator = Semaphore::Arbitrator.instance
  end
  
  # Test for the principal happy path:
  # given that no locks exist for a resource, we should be able to
  # acquire a lock.
  it "should be able to lock existing resources which are not locked" do
    bar_resource = Semaphore::Resource.create!(:name => 'bar resource', :capacity => 1)
    
    worked = false
    @arbitrator.lock(:name => 'bar resource') do
      worked = true
    end
    worked.should be_true
  end
  
  # Test for lock acquisition with automatic resource creation:
  # given a name for a resource which does not exist,
  # we should be able to acquire a lock on that resource.
  # In the process of lock acquisition the resource should be created.
  it "should be able to lock resources that do not exist, creating them first" do
    foo_resource = Semaphore::Resource.find_by_name('foo resource')
    foo_resource.should be_nil
    
    worked = false
    @arbitrator.lock(:name => 'foo resource', :create_resource => true, :capacity => 1) do
      worked = true
    end
    worked.should be_true
    
    foo_resource = Semaphore::Resource.find_by_name('foo resource')
    foo_resource.should_not be_nil
  end
  
  # Test for locking a resource that was previously locked and the lock
  # abandoned. The usual case when this happens is when ruby process
  # holding the lock gets killed due to an out-of-memory condition.
  # When processes terminate normally, all locks should be released
  # in ensure blocks by the arbitrator.
  it "should be able to lock resources which are abandoned" do
    bar_resource = Semaphore::Resource.create(:name => 'abandoned', :capacity => 1)
    allocations = bar_resource.allocations
    
    ticket = @arbitrator.acquire('abandoned', :timeout => 1)
    
    lambda do
      @arbitrator.lock(:name => 'abandoned', :wait => false) do
        raise 'Acquired a lock held by someone else'
      end
    end.should raise_exception(Semaphore::ResourceBusy)
    
    # exceed timeout on original allocation
    # mysql needs 2 seconds of waiting time here,
    # postgres works with 1 second
    sleep 2
    
    worked = false
    lambda do
      @arbitrator.lock(:name => 'abandoned', :wait => false) do
        worked = true
      end
    end.should_not raise_exception
    worked.should be_true
  end
  
  # Test for a case encountered in production: an allocation is reclaimed
  # without updating the resource usage count (or resource usage count is
  # incorrectly updated). For the time being we are going to have a manually
  # invokable method to fix the situation. (#781)
  #
  # This test uses factories because we're testing behavior with a specific
  # data combination.
  it "should be able to lock resources which have allocations in reclaimed state with usage at capacity" do
    resource = Factory.create(:singular_semaphore_resource,
      :name => 'test resource',
      :usage => 1,
      :capacity => 1
    )
    allocation = Factory.create(:semaphore_allocation,
      :resource => resource,
      :state => Semaphore::Allocation::RECLAIMED
    )
    
    # locking here should fail
    lambda do
      @arbitrator.lock(:name => 'test resource', :wait => false) do
        raise 'Acquired a lock when usage = capacity'
      end
    end.should raise_exception(Semaphore::ResourceBusy)
    
    # here we would fix up usages manually
    @arbitrator.recalculate_usages
    
    # now locking should succeed
    worked = false
    lambda do
      @arbitrator.lock(:name => 'test resource', :wait => false) do
        worked = true
      end
    end.should_not raise_exception
    worked.should be_true
    
    # here usage should be set to zero, since allocation has been released
    resource.reload
    resource.usage.should == 0
  end
  
  # Regression test for ticket #784. We allow releasing allocations that
  # have been reclaimed (in this case a process took an unexpectedly long
  # time to run but finished). We however cannot decrement resource usage
  # when releasing the resource because it was already decremented
  # when the allocation had been reclaimed.
  it "should not decrement resource usage when releasing reclaimed allocations" do
    resource = Factory.create(:singular_semaphore_resource,
      :name => 'test resource',
      # usage/capacity of 0 or 1 are bad choices because of clamping
      # to 0:infinity that we do; go with 2
      :usage => 2,
      :capacity => 2
    )
    allocation = Factory.create(:semaphore_allocation,
      :resource => resource,
      :state => Semaphore::Allocation::RECLAIMED
    )
    
    @arbitrator.release(allocation)
    
    resource.reload
    resource.usage.should == 2
  end
end
