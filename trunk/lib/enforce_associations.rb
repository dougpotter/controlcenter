module EnforceAssociations

  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def enforced_associations
      @@enforced_associations[self].to_a
    end 

    def belongs_to(association_id, options = {}) 
      update_enforced_associations(association_id, options)
      super
    end 

    def has_and_belongs_to_many(association_id, options = {}) 
      update_enforced_associations(association_id, options)
      super
    end

    def update_enforced_associations(association_id, options = {})
      @@enforced_associations ||= {}
      if options.delete(:enforce)
        @@enforced_associations[self] ||= Set.new
        @@enforced_associations[self] << association_id.to_s
      end 
    end
  end
end
