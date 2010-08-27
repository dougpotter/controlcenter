module ActiveRecord
  module Validations
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
    end
  end
end
