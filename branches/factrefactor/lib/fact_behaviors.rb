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
        debugger
        fa.add fact.find_by_sql(
          "SELECT #{group_by_list}, SUM(#{metric})
      FROM #{metric.pluralize}
      WHERE #{spec_hash[:where]}
      GROUP BY #{group_by_list}
      ")
      end 
      return fa
    end

    def find_all_by_dimensions(conditions)
    end

  end

  module InstanceMethods
    def self.included( base )
      # Method statements go here; e.g.:
      #validates_presence_of :start_time

    end

    # Instance methods go here

    def initialize(*args)
      relevant_params = scrub_params(args[0])
      translated_params = translate_to_db(relevant_params)
      super(translated_params)
    end

    def scrub_params(params)
      fact = ActiveRecord.const_get(self.class.to_s)
      attributes = fact.columns_hash.keys
      handelized_attributes = Dimension.translate_fks(attributes)
      relevant_params = {}
      for key in params.keys
        if handelized_attributes.member?(key)
          relevant_params[key] = params[key]
        end
      end
      relevant_params
    end

    def translate_to_db(params)
      translated_params = {}
      debugger
      params.each do |key, value|
        fk_name = Dimension.handle_to_fk(key)
        fk_value = Dimension.id_from_handle(key,value)
        debugger
        translated_params.merge({fk_name => fk_value})
      end
      translated_params
    end

    def save(*args)
    end

    def update(*args)
    end

    def say_hi
      puts "HI"
    end
  end
end
