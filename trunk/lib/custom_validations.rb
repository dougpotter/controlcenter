module ActiveRecord
  module Validations
    module ClassMethods

      def validates_as_date(*attr_names)
        configuration = { :message => "attribute should be of type Date" }
        configuration.update(attr_names.extract_options!)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless value.class == Date
            record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value)
          end
        end
      end


      def validates_temporal_consistency(*attr_names)
        configuration = { :message => "end date precedes start date" }
        configuration.update(attr_names.extract_options!)

        raise(ArgumentError, "#{attr_names.size} for 2") unless attr_names.size == 2

        validates_each(attr_names, configuration) do |record, attr_name, value|
          if record.start_date > record.end_date && !record.errors.invalid?(:start_date) && !record.errors.invalid?(:end_date)
            record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value)
          end
        end
      end
    end
  end
end
