module DimensionCache

  # look through /app/models and determin which files are ActiveRecord Dimensions
  def self.find_dimensions
    dimensions = []
    model_strings = Dir.glob("app/models/**").map { |f| f.match(/\/+([a-z_]+)\./)[1] }
    for model_string in model_strings
      # bypass all but ActiveRecord Dimensions
      begin
        model_class = ActiveRecord.const_get(model_string.classify)
        next unless model_class.is_dimension? && model_class.superclass == ActiveRecord::Base
        dimensions << model_class
      rescue NameError
        next
      end
    end

    return dimensions
  end

  def self.seed_relationships(options = {})
    for dimension_class in self.find_dimensions
      model_string = dimension_class.class.to_s.underscore
      relationships = []
      if relations = dimension_class.enforced_associations
        for relation in relations
          relationships << [ model_string, relation ]
        end   
      end

      if !relationships.empty?
        for instance in dimension_class.all
          dim_red_code_name = instance.class.to_s.underscore + "_id"
          dim_red_code_value = instance.id
          dim_blue_code_name = ""
          dim_blue_code_value = "" 

          relationships.each do |relationship|
            for relation in [ instance.send(relationship[1]) ].flatten
              dim_blue_code_name = relation.class.to_s.underscore + "_id"
              dim_blue_code_value = relation.id
              dim_red_component = 
                dim_red_code_name.to_s + ":" + dim_red_code_value.to_s
              dim_blue_component = 
                dim_blue_code_name.to_s + ":" + dim_blue_code_value.to_s
              cache_string = 
                [ dim_red_component, dim_blue_component ].sort.join(":")
              puts cache_string if options[:verbose]
              CACHE.write(cache_string, true)
            end   
          end   
        end   
      end
    end
  end

  def self.reset
    CACHE.clear
  end
end
