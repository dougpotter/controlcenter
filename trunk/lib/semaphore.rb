module Semaphore
  class SemaphoreError < StandardError; end
  class ResourceNotFound < SemaphoreError; end
  class AllocationStateWrong < SemaphoreError; end
  
  class ResourceBusy < SemaphoreError
    attr_reader :timeout
    
    def initialize(message, timeout=nil)
      super(message)
      @timeout = timeout
    end
  end
  
  class Arbitrator
    def acquire(name, options={})
      location = options[:location]
      timeout = options[:timeout] || 1.hour
      
      resource = Resource.identity(name, location).first
      if resource.nil?
        raise ResourceNotFound, "No resource matching name and location"
      end
      
      if resource.usage >= resource.capacity
        raise ResourceBusy, "Resource busy: #{name}#{location ? " at #{location}" : ''}"
      end
      
      allocation = Allocation.new(:resource => resource, :expires_at => Time.now + timeout)
      Resource.transaction do
        allocation.save!
        
        # don't use attribute assignment+save to avoid accidental overwrites
        Resource.update_all('usage = usage + 1', ['id = ?', resource.id])
      end
      
      allocation.id
    end
    
    def release(allocation_id)
      allocation = Allocation.find(allocation_id)
      if allocation.state != Allocation::ALLOCATED && allocation.state != Allocation::RECLAIMED
        raise AllocationStateWrong, "Allocation is in wrong state: #{allocation.state}"
      end
      
      allocation.state = Allocation::RELEASED
      Resource.transaction do
        allocation.save!
        Resource.update_all('usage = (case when usage > 1 then usage - 1 else 0 end)', ['id = ?', allocation.resource.id])
      end
      
      true
    end
    
    def extend(allocation_id, options={})
      timeout = options[:timeout] || 1.hour
      
      allocation = Allocation.find(allocation_id)
      if allocation.state != Allocation::ALLOCATED
        raise AllocationStateWrong, "Allocation is in wrong state: #{allocation.state}"
      end
      
      allocation.expires_at = Time.now + timeout
      allocation.save!
      
      true
    end
  end
  
  class Resource < ActiveRecord::Base
    has_many :allocations, :class_name => "Semaphore::Allocation", :foreign_key => 'semaphore_resource_id'
    
    set_table_name :semaphore_resources
    
    def initialize(options={})
      default_options = {:usage => 0}
      super(default_options.update(options))
    end
    
    named_scope :identity do |*args|
      name, location = args
      conditions = ['name = ?', name]
      if location
        conditions.first << ' and location = ?'
        conditions.last << location
      else
        conditions.first << ' and location is null'
      end
      {:conditions => conditions}
    end
    
    validates_presence_of :name
    validates_presence_of :capacity
    validates_presence_of :usage
    validates_each :location do |record, attr, value|
      if record.new_record?
        base_scope = self
      else
        base_scope = self.scoped(:conditions => ['id <> ?', record.id])
      end
      
      if value.nil?
        scope = base_scope.scoped(:conditions => ['name = ?', record.name])
        other = scope.find(:first)
        if other
          if other.location
            record.errors.add(:location, 'cannot be nil because other records exist with non-nil location')
          else
            record.errors.add(:location, 'cannot be nil because another record already exists (with nil location)')
          end
        end
      else
        scope = base_scope.scoped(:conditions => ['name = ? and (location = ? or location is null)', record.name, value])
        other = scope.find(:first)
        if other
          if other.location
            record.errors.add(:location, "is not unique within name: #{record.name}")
          else
            record.errors.add(:location, 'cannot be non-nil because another record exists with nil location')
          end
        end
      end
    end
  end
  
  class Allocation < ActiveRecord::Base
    belongs_to :resource, :class_name => "Semaphore::Resource", :foreign_key => 'semaphore_resource_id'
    
    set_table_name :semaphore_allocations
    
    ALLOCATED = 1
    RELEASED = 2
    RECLAIMED = 3
    
    def initialize(options={})
      default_options = {:state => ALLOCATED}
      options = default_options.update(options)
      # more expensive operations
      options[:created_at] ||= Time.now
      options[:host] ||= Socket.gethostname
      options[:pid] ||= $$
      options[:tid] ||= Thread.current.object_id
      super(options)
    end
    
    validates_presence_of :resource
    validates_presence_of :created_at
    validates_presence_of :expires_at
    validates_presence_of :state
  end
end
