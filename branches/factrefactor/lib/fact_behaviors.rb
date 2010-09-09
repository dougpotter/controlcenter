module FactBehaviors

  def self.included(base)
    base.class_eval do
      def self.acts_as_fact
        extend  ClassMethods
        include InstanceMethods
      end
    end
  end

  module ClassMethods
    # Class methods go here
    # takes hash of include, group_by, where, and frequency params and
    # returns object of type FactAggreation
    # TODO: I'd like to separate the building of group_by_list into its
    # own method, but I don't know how within a module
    def aggregate(spec_hash)
      group_by_list = keyize_indices(spec_hash[:group_by])

      fa = FactAggregation.new
      for metric in spec_hash[:include]
        fact = ActiveRecord.const_get(metric.classify)
        fa.add fact.find_by_sql(
          "SELECT #{group_by_list}, SUM(#{metric})
          FROM #{metric.pluralize}
          WHERE #{spec_hash[:where]}
          GROUP BY #{group_by_list}"
        )
      end 
      fa.adjust_time_zone(spec_hash[:tz_offset])
      return fa
    end

    # TODO: Write test to verify behavior of this function
    def is_fact?(sym_or_class_or_str = nil)
      return case sym_or_class_or_str
      when Symbol then
        is_fact?(sym_or_class_or_str.to_s)
      when String then
        begin
          is_fact?(const_get(sym_or_class_or_str.classify))
        rescue
          false
        end
      when Class then
        sym_or_class_or_str.respond_to?("is_fact?") && 
          sym_or_class_or_str.send("is_fact?")
      when NilClass then true
      else false
      end
    end

    def dimension_columns
      columns_hash.keys.delete_if { |k|
        k.match(/.*_count$/) || k == "id"
      }
    end

    def find_all_by_dimensions(conditions)
    end
    
    def native_attributes?(params)
      fact = ActiveRecord.const_get(self.name)
      native_attribute_set = fact.columns_hash.keys.to_set
      
      params.keys.map{|a| a.to_s}.to_set.subset?(native_attribute_set)
    end
    
    def keyize_index_attributes(index_attributes)
      Dimension.keyize_index_attributes(index_attributes, {
        :include => scalar_dimensions
      })
    end
    
    def keyize_indices(business_indices)
      Dimension.keyize_indices(business_indices)
    end
    
    def scalar_dimensions
      Dimension.scalar_dimensions.push(
        self.name.to_s.tableize.singularize.to_sym
      )
    end
  end

  module InstanceMethods
    def self.included( base )
      # Method statements go here; e.g.:
      #base.validates_presence_of :start_time
      if base.respond_to?(:validates_as_unique)
        base.validates_as_unique
      end
    end

    # Instance methods go here

    def initialize(attributes = nil)
      if attributes.nil? || attributes.empty? || self.class.native_attributes?(attributes)
        super
      else
        translated_params = self.class.keyize_index_attributes(attributes)
        super(translated_params)
      end
    end
    
    def is_fact? ; true ; end

    def update(*args)
    end
    
  end
end
