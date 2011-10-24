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
          relationships.each do |relationship|
            for relation in [ instance.send(relationship[1]) ].flatten
              cache_string = self.cache_string_from_records(instance,relation)
              puts cache_string if options[:verbose]
              Rails.cache.write(cache_string, true)
            end   
          end   
        end   
      end
    end
  end

  def self.cache_string_from_records(red_record, blue_record)
    red_model_name = red_record.class.to_s.underscore + "_id"
    blue_model_name = blue_record.class.to_s.underscore + "_id"
    red_model_value = red_record.id.to_s
    blue_model_value = blue_record.id.to_s
    red_string = red_model_name + ":" + red_model_value
    blue_string = blue_model_name + ":" + blue_model_value
    cache_string = [ red_string, blue_string ].sort.join(":")
  end

  def self.reset
    Rails.cache.clear
  end
end
