module ActiveRecord
  module Validations
    module ClassMethods

      def validates_as_date(*attr_names)
        configuration = { :message => "attribute should be of type Date" }
        configuration.update(attr_names.extract_options!)

        validates_each(*attr_names) do |record, attr_name, value|
          unless value.is_a?(Date)
            record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value)
          end
        end
      end


      def validates_temporal_consistency(start_attr_name, end_attr_name, options={})
        configuration = { :message => "end date precedes start date" }
        configuration.update(options)

        validates_each(start_attr_name) do |record, attr_name, value|
          if record.send(start_attr_name) > record.send(end_attr_name)
            record.errors.add(start_attr_name, :invalid, :default => configuration[:message], :value => value)
          end
        end
      end
    end
  end
end
