module CustomValidations
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods

    # This validation comes from here:
    # https://gist.github.com/102138
    #
    #
    # Validates whether the value of the specified attribute matches the format of an URL,
    # as defined by RFC 2396. See URI#parse for more information on URI decompositon and parsing.
    #
    # This method doesn't validate the existence of the domain, nor it validates the domain itself.
    #
    # Allowed values include http://foo.bar, http://www.foo.bar and even http://foo.
    # Please note that http://foo is a valid URL, as well http://localhost.
    # It's up to you to extend the validation with additional constraints.
    #
    #   class Site < ActiveRecord::Base
    #     validates_format_of :url, :on => :create
    #     validates_format_of :ftp, :schemes => [:ftp, :http, :https]
    #   end
    #
    # ==== Configurations
    #
    # * <tt>:schemes</tt> - An array of allowed schemes to match against (default is <tt>[:http, :https]</tt>)
    # * <tt>:message</tt> - A custom error message (default is: "is invalid").
    # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute is +nil+ (default is +false+).
    # * <tt>:allow_blank</tt> - If set to true, skips this validation if the attribute is blank (default is +false+).
    # * <tt>:on</tt> - Specifies when this validation is active (default is <tt>:save</tt>, other options <tt>:create</tt>, <tt>:update</tt>).
    # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the validation should
    #   occur (e.g. <tt>:if => :allow_validation</tt>, or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>).  The
    #   method, proc or string should return or evaluate to a true or false value.
    # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
    #   not occur (e.g. <tt>:unless => :skip_validation</tt>, or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>).  The
    #   method, proc or string should return or evaluate to a true or false value.
    #
    def validates_format_of_url(*attr_names)
      require 'uri/http'

      configuration = { :on => :save, :schemes => %w(http https) }
      configuration.update(attr_names.extract_options!)

      allowed_schemes = [*configuration[:schemes]].map(&:to_s)

      validates_each(attr_names, configuration) do |record, attr_name, value|
        begin
          uri = URI.parse(value)

          if !allowed_schemes.include?(uri.scheme)
            raise(URI::InvalidURIError)
          end

          if [:scheme, :host].any? { |i| uri.send(i).blank? }
            raise(URI::InvalidURIError)
          end

        rescue URI::InvalidURIError => e
          record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value)
          next
        end
      end
    end

    # Validates that none of the attributes passed are present

    def validates_absence_of(*attr_names)
      validates_each(attr_names) do |record, attr_name, value|
        if record.send(attr_name)
          record.errors.add(
            attr_name,
            :invalid,
            :default => "mistakenly tried to instantiate #{self.to_s} with attribute \"#{attr_name}\""
          )
        end
      end
    end

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

    def validates_as_increasing(first_attr, second_attr, options = {})
      configuration = { 
        :message => options[:message] || "attribute fails to increase in value" }

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
