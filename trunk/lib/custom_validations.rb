module CustomValidations
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end
  
  module ClassMethods

    # Validates that specified attributes are of type Time.
    #
    # Configuration Options:
    # :allow_nil - skip validation if attribute is nil, default is true

    def validates_as_datetime(*attr_names)
      configuration = { :message => "attribute should be of type Time" }
      validates_each(attr_names, configuration) do |record, attr_name, value|
        unless value.is_a?(Time)
          record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value)
        end
      end
    end

    # Validates that specified attributes are of type date.
    #
    # Configuration Options:
    # :allow_nil - skip validation if attribute is nil, default is true

    def validates_as_date(*attr_names)
      configuration = { :message => "attribute should be of type Date" }
      validates_each(attr_names, configuration) do |record, attr_name, value|
        unless value.is_a?(Date)
          record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value)
        end
      end
    end

    # Validates that attributes provided are in order of increasing value.
    #
    # Configuration Options:
    # :allow_nil - skips validation if either attribute is nil

    def validates_as_increasing(first_attr, second_attr)
      configuration = { :message => "attribute fails to increase in value" }

      validates_each(first_attr) do |record, attr_name, value|
        next if (record.send(first_attr).nil? || record.send(second_attr).nil?)
        if record.send(first_attr) > record.send(second_attr)
          record.errors.add(second_attr, :invalid, :default => configuration[:message], :value => value)
        end
      end
    end

    # validate uniquenss of required attribute combo
    def validates_as_unique(options = {})
      validated_columns = self.dimension_columns.map { |c| c.to_sym }
      return if validated_columns.empty?
      validates_each(validated_columns.first, options) do |record, attr_name, value|
        where_parts = []
        validated_columns.each do |column|
          value = record.send(column)
          if value.nil?
            # ignore
          elsif column == :start_time || column == :end_time
            where_parts << "#{connection.quote_table_name(column)} = #{quote_value(value.strftime("%Y-%m-%d %H:%M:%S"))}"
          else
            where_parts << "#{connection.quote_table_name(column)} = #{quote_value(value)}"
          end
        end
        
        if !where_parts.empty?
          # don't need this since we only validate as unique on create currently
          #unless record.new_record?
            #where_parts << "#{connection.quote_table_name(primary_key)} <> #{quote_value(record.send(primary_key))}"
          #end
          
          duplicates = self.find_by_sql("SELECT 1 FROM #{connection.quote_table_name(self.to_s.underscore.pluralize)} WHERE #{where_parts.join(" AND ")}")
          unless duplicates.empty?
            record.errors.add_to_base("Set of dimension columns is not unique")
          end 
        else
          record.errors.add_to_base('All columns in validates_as_unique constraint have nil values')
        end
      end
    end 
  end
end
