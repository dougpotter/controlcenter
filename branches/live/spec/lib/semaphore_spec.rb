require 'spec_helper'

describe Semaphore::Arbitrator do
  before :each do
    @arbitrator = Semaphore::Arbitrator.instance
  end
  
  it "should be able to lock existing resources which are not locked" do
    bar_resource = Semaphore::Resource.create!(:name => 'bar resource', :capacity => 1)
    
    worked = false
    @arbitrator.lock(:name => 'bar resource') do
      worked = true
    end
    worked.should be_true
  end
  
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
  
  it "should be able to lock resources which are abandoned" do
    bar_resource = Semaphore::Resource.create(:name => 'abandoned', :capacity => 1)
    allocations = bar_resource.allocations
    
    ticket = @arbitrator.acquire('abandoned', :timeout => 1)
    
    lambda do
      @arbitrator.lock(:name => 'abandoned', :wait => false) do
        raise 'Should not get here'
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
end
