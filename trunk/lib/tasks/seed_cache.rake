namespace :dimension_cache do

  desc "Seed cache with dimension values and relationships"
  task :seed => [ :environment, :reset ] do
    model_strings = Dir.glob("app/models/**").map { |f| f.match(/\/+([a-z_]+)\./)[1] }

    for model_string in model_strings
      # bypass all but ActiveRecord Dimensions
      begin
        model_class = ActiveRecord.const_get(model_string.classify)
        next unless model_class.is_dimension? && model_class.superclass == ActiveRecord::Base
      rescue NameError
        next
      end

      #seed dimension values
      model_code = model_class.business_code
      known_values = model_class.all.map { |m| m.business_code_value }
      for value in known_values
        CACHE.write(model_code.to_s + ":" + value.to_s, true)
      end

      # seed dimension relationships
      relationships = []
      if relations = model_class.enforced_associations
        for relation in relations
          relationships << [ model_string, relation ]
        end
      end

      # i use red and blue to avoid any connotation of order. the dimension
      # code-value pairs are ordered alphabetically, by dimension code name, 
      # just before being placed in the cache
      if !relationships.empty?
        for instance in model_class.all
          dim_red_code_name = instance.business_code
          dim_red_code_value = instance.business_code_value
          dim_blue_code_name = ""
          dim_blue_code_value = ""

          relationships.each do |relationship|
            for relation in instance.send(relationship[1]).to_a
              dim_blue_code_name = relation.business_code
              dim_blue_code_value = relation.business_code_value
              dim_red_component = 
                dim_red_code_name.to_s + ":" + dim_red_code_value.to_s
              dim_blue_component = 
                dim_blue_code_name.to_s + ":" + dim_blue_code_value.to_s
              cache_string = 
                [ dim_red_component, dim_blue_component ].sort.join(":")
              puts cache_string
              CACHE.write(cache_string, true)
            end
          end
        end
      end
    end
  end

  desc "Delete contents of cache"
  task :reset => :environment  do
    CACHE.reset
  end
end
