require 'singleton'

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
    include Singleton
    
    def acquire(name, options={})
      location = options[:location]
      timeout = options[:timeout] || 1.hour
      
      resource = Resource.identity(name, location).first
      if resource.nil?
        raise ResourceNotFound, "No resource matching name and location"
      end
      
      if resource.usage >= resource.capacity
        # try to reclaim abandoned allocations
        allocations = Allocation.abandoned
        unless allocations.empty?
          Allocation.transaction do
            Allocation.update_all(
              ['state = ?', Allocation::RECLAIMED],
              ['id in (?)', allocations.map { |allocation| allocation.id }]
            )
            Resource.recalculate_usage(resource.id)
          end
          
          # reload resource to account for concurrent modification,
          # either by arbitrator or because capacity changed
          resource.reload
          
          fail = resource.usage >= resource.capacity
        else
          fail = true
        end
        
        if fail
          raise ResourceBusy, "Resource busy: #{name}#{location ? " at #{location}" : ''}"
        end
      end
      
      allocation = Allocation.new(:resource => resource, :expires_at => Time.zone.now + timeout)
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
        Resource.decrement_usage(allocation.resource.id)
      end
      
      true
    end
    
    def extend(allocation_id, options={})
      timeout = options[:timeout] || 1.hour
      
      allocation = Allocation.find(allocation_id)
      if allocation.state != Allocation::ALLOCATED
        raise AllocationStateWrong, "Allocation is in wrong state: #{allocation.state}"
      end
      
      allocation.expires_at = Time.zone.now + timeout
      allocation.save!
      
      true
    end
    
    # Accepted options:
    #
    # :name (required)
    # :location
    # :capacity (required for creating resource)
    # :timeout (should be provided)
    # :wait
    # :wait_retries (required if :wait is true)
    # :wait_sleep (required if :wait is true)
    # :debug_callback
    # :create_resource
    def lock(options)
      allocation = nil
      attempt = 0
      begin
        if options[:debug_callback]
          options[:debug_callback].call('Trying to acquire lock')
        end
        
        allocation = acquire(
          options[:name],
          :location => options[:location],
          :timeout => options[:timeout]
        )
      rescue ResourceNotFound
        if options[:create_resource]
          if options[:debug_callback]
            options[:debug_callback].call('Trying to create resource')
          end
          
          resource = Resource.soft_create(
            :name => options[:name],
            :location => options[:location],
            :capacity => options[:capacity]
          )
          retry
        else
          raise
        end
      rescue ResourceBusy
        if options[:wait]
          if attempt >= options[:wait_retries]
            raise
          else
            if options[:debug_callback]
              options[:debug_callback].call('Waiting for busy lock')
            end
            
            sleep options[:wait_sleep]
            attempt += 1
            retry
          end
        else
          raise
        end
      end
      
      begin
        yield
      ensure
        if options[:debug_callback]
          options[:debug_callback].call('Releasing lock')
        end
        
        release(allocation)
      end
    end
  end
  
  class Resource < ActiveRecord::Base
    has_many :allocations, :class_name => "Semaphore::Allocation", :foreign_key => 'semaphore_resource_id'
    
    set_table_name :semaphore_resources
    
    def initialize(options={})
      default_options = {:usage => 0}
      super(default_options.update(options))
    end
    
    named_scope :identity, lambda { |*args|
      name, location = args
      conditions = ['name = ?', name]
      if location
        conditions.first << ' and location = ?'
        conditions << location
      else
        conditions.first << ' and location is null'
      end
      {:conditions => conditions}
    }
    
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
    
    class << self
      # note that this method accepts nil ids (which would be a no-op)
      def decrement_usage(id)
        update_all('usage = (case when usage > 1 then usage - 1 else 0 end)', ['id = ?', id])
      end
      
      def recalculate_usage(id)
        update_all(
          ["usage = (select count(*) from #{Allocation.quoted_table_name} where semaphore_resource_id = #{Resource.quoted_table_name}.id and state=?)", Allocation::ALLOCATED],
          ['id = ?', id]
        )
      end
      
      def soft_create(attrs)
        unless attrs[:name] && attrs[:capacity]
          raise ArgumentError, "Attributes must at least specify :name and :capacity"
        end
        
        resource = new(attrs)
        begin
          resource.save!
        rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid
          if resource = identity(attrs[:name], attrs[:location])
            resource
          else
            raise
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
      options[:created_at] ||= Time.zone.now
      options[:host] ||= Socket.gethostname
      options[:pid] ||= $$
      options[:tid] ||= Thread.current.object_id
      super(options)
    end
    
    named_scope :abandoned, lambda {
      {:conditions => ['state = ? and expires_at < ?', ALLOCATED, Time.zone.now]}
    }
    
    def abandoned?
      state == ALLOCATED && expires_at < Time.zone.now
    end
    
    after_destroy :adjust_resource_usage
    
    def adjust_resource_usage
      if state == ALLOCATED
        Resource.decrement_usage(semaphore_resource_id)
      end
    end
    private :adjust_resource_usage
    
    validates_presence_of :resource
    validates_presence_of :created_at
    validates_presence_of :expires_at
    validates_presence_of :state
  end
end
