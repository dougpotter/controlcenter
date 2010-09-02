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

    def is_fact?
      true
    end
  end

  module InstanceMethods
    def self.included( base )
      # Method statements go here; e.g.:
      #validates_presence_of :start_time

    end

    # Instance methods go here

    def initialize(*args)
      fact = ActiveRecord.const_get(self.class.to_s)
      attributes = fact.columns_hash.keys
      if args == [] || params_are_subset(args[0], attributes)
        super
      else
        relevant_params = scrub_params(args[0])
        translated_params = translate_to_db(relevant_params)
        super(translated_params)
      end
    end

    def params_are_subset(params, attributes)
        params.keys.map{|a| a.to_s}.to_set.subset?(attributes.to_set)
    end


    def scrub_params(params)
      fact = ActiveRecord.const_get(self.class.to_s)
      attributes = fact.columns_hash.keys
      if params.keys.to_set.subset?(attributes.to_set)
        return params
      else
        handelized_attributes = Dimension.translate_fks(attributes)
        relevant_params = {}
        for key in params.keys
          if handelized_attributes.member?(key)
            relevant_params[key] = params[key]
          end
        end
        relevant_params
      end
    end

    def translate_to_db(params)
      translated_params = {}
      params.each do |key, value|
        if Dimension.model_dimensions.member?(key[0..-6]) || key == "ais_code"
          fk_name = Dimension.handle_to_fk(key)
          fk_value = Dimension.id_from_handle(key,value)
          translated_params.merge!({fk_name => fk_value})
        else
          translated_params.merge!({key => value})
        end
      end
      translated_params
    end

    def update(*args)
    end

    def say_hi
      puts "HI"
    end
  end
end
