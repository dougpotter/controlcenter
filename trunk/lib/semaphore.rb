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
      
      # transaction method returns nil instead of the result of yielded block,
      # requiring us to scope allocation outside of the block
      allocation = nil
      
      # transaction should encompass all read queries
      Allocation.transaction do
        resource = Resource.identity(name, location).first
        if resource.nil?
          raise ResourceNotFound, "No resource matching name and location"
        end
        
        if resource.usage >= resource.capacity
          # try to reclaim abandoned allocations
          allocations = resource.allocations.abandoned
          unless allocations.empty?
            num_updated = Allocation.update_all(
              ['state = ?', Allocation::RECLAIMED],
              ['id in (?)', allocations.map { |allocation| allocation.id }]
            )
            Resource.alter_usage(resource.id, -num_updated)
            # update our object for subsequent calculation
            resource.usage -= num_updated
            
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
        allocation.save!
        
        # don't use attribute assignment+save to avoid accidental overwrites
        Resource.alter_usage(resource.id, 1)
      end
      
      allocation.id
    end
    
    def release(allocation_id)
      # transaction should encompass all read queries
      Allocation.transaction do
        allocation = Allocation.find(allocation_id)
        if allocation.state != Allocation::ALLOCATED && allocation.state != Allocation::RECLAIMED
          raise AllocationStateWrong, "Allocation is in wrong state: #{allocation.state}"
        end
        
        allocation.state = Allocation::RELEASED
        allocation.save!
        Resource.alter_usage(allocation.resource.id, -1)
      end
      
      true
    end
    
    def extend(allocation_id, options={})
      timeout = options[:timeout] || 1.hour
      
      # need transaction here to guard against concurrent modification of
      # the allocation
      Allocation.transaction do
        allocation = Allocation.find(allocation_id)
        if allocation.state != Allocation::ALLOCATED
          raise AllocationStateWrong, "Allocation is in wrong state: #{allocation.state}"
        end
        
        allocation.expires_at = Time.zone.now + timeout
        allocation.save!
      end
      
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
        rv = yield
      ensure
        if options[:debug_callback]
          options[:debug_callback].call('Releasing lock')
        end
        
        release(allocation)
      end
      rv
    end
    
    def recalculate_usages
      quoted_usage = Resource.connection.quote_column_name('usage')
      Resource.update_all(
        ["#{quoted_usage} = (select count(*) from #{Allocation.quoted_table_name} where semaphore_resource_id = #{Resource.quoted_table_name}.id and state=?)", Allocation::ALLOCATED]
      )
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
      def alter_usage(id, delta)
        # usage is a reserved word on mysql, and thus must be quoted
        quoted_usage = quote_identifier('usage')
        quoted_delta = quote_value(delta)
        # XXX clamping usage to 0:infinity here may mask problems
        update_all("#{quoted_usage} = (case when #{quoted_usage} + #{quoted_delta} > 0 then #{quoted_usage} + #{quoted_delta} else 0 end)", ['id = ?', id])
      end
      
      def recalculate_usage(id)
        quoted_usage = Resource.connection.quote_column_name('usage')
        update_all(
          ["#{quoted_usage} = (select count(*) from #{Allocation.quoted_table_name} where semaphore_resource_id = #{Resource.quoted_table_name}.id and state=?)", Allocation::ALLOCATED],
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
    
    after_destroy :adjust_resource_usage_on_destruction
    
    def adjust_resource_usage_on_destruction
      if state == ALLOCATED
        Resource.alter_usage(semaphore_resource_id, -1)
      end
    end
    private :adjust_resource_usage_on_destruction
    
    validates_presence_of :resource
    validates_presence_of :created_at
    validates_presence_of :expires_at
    validates_presence_of :state
  end
end
