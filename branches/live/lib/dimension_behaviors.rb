module DimensionBehaviors
  class InvalidDimensionSpecification < Exception ; end

  def self.included(base)
    base.class_eval do

      def self.acts_as_dimension
        extend  ClassMethods
        include InstanceMethods
      end

    end
  end

  module ClassMethods
    # Class methods go here
    
    def business_index_dictionary ; @@business_index_dictionary ; end
    def business_index_aliases ; @@business_index_aliases ; end

    # Valid options:
    #   :as => 
    #   :aka => 
    def business_index(index_column, options = {})
      pkey = self.name.foreign_key.to_sym
      @@business_index_dictionary ||= HashWithIndifferentAccess.new
      @@business_index_aliases ||= HashWithIndifferentAccess.new
      if options[:as]
        case options[:as]
        when nil then nil
        when Array then 
          options[:as].each do |as_el|
            @@business_index_dictionary[as_el] = pkey
            @@business_index_aliases[as_el] = index_column
          end
        else
          @@business_index_dictionary[options[:as]] = pkey
          @@business_index_aliases[options[:as]] = index_column
        end
              
      elsif options[:aka]
        case options[:aka]
        when nil then nil
        when Array then 
          options[:aka].push(index_column).each do |as_el|
            @@business_index_dictionary[as_el] = pkey
            @@business_index_aliases[as_el] = index_column
          end
        else
          [options[:aka], index_column].each do |as_el|
            @@business_index_dictionary[as_el] = pkey
            @@business_index_aliases[as_el] = index_column
          end
        end
        
      else
        @@business_index_dictionary[index_column] = pkey
        @@business_index_aliases[index_column] = index_column
      end
    end
    
    # TODO: Implement this method as necessary
    def business_indices(*args)
    end
    alias :business_indexes :business_indices
    
    
    def find_by_business_index(param, arg)
      translated_rows = 
        const_get(
          @@business_index_dictionary[param].to_s.gsub(/_id$/, "").classify
        ).send("find_all_by_#{@@business_index_aliases[param].to_s}", arg)
      if translated_rows.size > 1
        raise "Multiple rows for single business index value"
      end
      translated_rows = translated_rows[0]
    end
    
    def keyize_index_attributes(attributes = nil, options = {})
      return {} if attributes.nil?
      
      key_attrs = {}
      attributes.each do |param, arg|
        # Business indices
        if @@business_index_dictionary.include?(param)
          translated_arg = nil
          if (row = find_by_business_index(param, arg))
            translated_arg = row.id
          else
            translated_arg = nil
          end
          
          if key_attrs[@@business_index_dictionary[param]].nil? ||
              key_attrs[@@business_index_dictionary[param]] == translated_arg
            key_attrs[@@business_index_dictionary[param]] = translated_arg
          else
            raise InvalidDimensionSpecification
          end
          
        # Scalar indices; no translation
        elsif options[:include] && 
            (options[:include].include?(param.to_sym) || 
            options[:include].include?(param.to_s))
          key_attrs[param] = arg
        end
      end
      return key_attrs
    end
    
    def keyize_indices(business_indices)
      return [] if business_indices.nil? || business_indices.empty?
      
      return (business_indices.collect { |idx|
        Dimension.scalar_dimensions.include?(idx.to_sym) ?
          idx.to_sym :
          @@business_index_dictionary[idx]
      }.compact.uniq)
    end
        
    def scalar_dimensions
      [ :start_time, :end_time, :duration_in_minutes ]
    end
    
  end

  module InstanceMethods
    def self.included( base )
      # Method statements go here; e.g.:
    end

    # Instance methods go here
  end

end

ActiveRecord::Base.class_eval do
  include DimensionBehaviors
end
