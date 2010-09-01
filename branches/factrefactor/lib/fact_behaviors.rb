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
    def self.aggregate(spec_hash)
      group_by_list = spec_hash[:group_by].collect { |dim|
        if Dimension.model_dimensions.member?(dim)
          dim += "_id"
        else 
          dim 
        end 
      }.join(",")

      fa = FactAggregation.new
      for metric in spec_hash[:include]
        fact = ActiveRecord.const_get(metric.classify)
        fa.add fact.find_by_sql(
          "SELECT #{group_by_list}, SUM(#{metric})
      FROM #{metric.pluralize}
      WHERE #{spec_hash[:where]}
      GROUP BY #{group_by_list}
      ")
      end 
      return fa
    end

  end

  module InstanceMethods
    def self.included( base )
      # Method statements go here; e.g.:
      #validates_presence_of :start_time

    end

    # Instance methods go here
  end

end
