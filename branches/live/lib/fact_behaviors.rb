module FactBehaviors
  TIME_FORMAT = "%Y-%m-%d %H:%M:%S".freeze

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

    # fills fact aggregation object with appropriate facts according to parsed
    # params hash (options) 
    def aggregate(fa, options = {})
      for metric in options[:include]
        options[:fact] = metric
        fact = Object.const_get(metric.classify)
        if fact.is_additive?
          AdditiveFact.aggregate(fa, options)
        else
          UniqueFact.aggregate(fa, options)
        end
      end 

      fa.adjust_time_zone(options[:tz_offset])
      return fa
    end

    # fills group_by_list and column_aliases with appropriate SQL given the
    # supplied frequency
    def parse_frequency_for_grouping(fact_table, frequency, group_by_list, column_aliases)
      case frequency
      when "hour"
        date = SqlGenerator.date_from_datetime('start_time', {:fact_table => fact_table})
        hour = SqlGenerator.hour_from_datetime('start_time', {:fact_table => fact_table})
        group_by_list.concat([date, hour])
        column_aliases[date] = 'date'
        column_aliases[hour] = 'hour'
      when "day"
        date = SqlGenerator.date_from_datetime('start_time', {:fact_table => fact_table})
        group_by_list << date
        column_aliases[date] = 'date'
      when "week"
        start_date = SqlGenerator.beginning_of_week_from_datetime('start_time', {:fact_table => fact_table})
        column_aliases[start_date] = 'start_date'
        group_by_list << start_date
      when "month"
        start_date = SqlGenerator.beginning_of_month_from_datetime('start_time', {:fact_table => fact_table})
        group_by_list << start_date
        column_aliases[start_date] = 'start_date'
      when nil
        raise ArgumentError, "Frequency must be given in current implementation"
      else
        raise ArgumentError, "Unknown frequency: #{frequency}"
      end
    end

    # TODO: Write test to verify behavior of this function
    def is_fact?(sym_or_class_or_str = nil)
      return case sym_or_class_or_str
    when Symbol then
      is_fact?(sym_or_class_or_str.to_s)
    when String then
      begin
        is_fact?(const_get(sym_or_class_or_str.classify))
      rescue
        false
      end
    when Class then
      sym_or_class_or_str.respond_to?("is_fact?") && 
        sym_or_class_or_str.send("is_fact?")
    when NilClass then true
    else false
    end
  end

  def dimension_columns
    columns_hash.keys.delete_if { |k|
      k.match(/.*_count$/) || k == "id"
    }
  end

  def find_all_by_dimensions(options = {})
    find(:all, {
      :conditions => keyize_index_attributes(options[:conditions])
    })
  end

  def native_attributes?(params)
    fact = ActiveRecord.const_get(self.name)
    native_attribute_set = fact.columns_hash.keys.to_set

    params.keys.map{|a| a.to_s}.to_set.subset?(native_attribute_set)
  end

  def keyize_index_attributes(index_attributes, options = {})
    Dimension.keyize_index_attributes(index_attributes, {
      :include => (
        options[:include_fact] ?
        Dimension.scalar_dimensions.push(scalar_fact) :
        Dimension.scalar_dimensions
    )
    })
  end

  def keyize_indices(business_indices)
    Dimension.keyize_indices(business_indices)
  end

  def scalar_fact
    self.name.to_s.underscore.to_sym
  end
end

module InstanceMethods
  def self.included( base )
    # Method statements go here; e.g.:
    #base.validates_presence_of :start_time
    if base.respond_to?(:validates_as_unique)
      base.validates_as_unique :on => :create
    end

    Dimension.business_index_dictionary.each do |key, value|
      base.class_eval do
        define_method(key) {
          begin 
            self.send(value.to_s.gsub(/_id$/, "")).send(
              Dimension.business_index_aliases[key]
            )
          rescue 
            nil
          end
        }
      end
    end
  end

  # Instance methods go here

  def initialize(attributes = nil)
    if attributes.nil? || attributes.empty? || self.class.native_attributes?(attributes)
      super
    else
      translated_params = self.class.keyize_index_attributes(attributes, {
        :include_fact => true
      })
      super(translated_params)
    end
  end

  def update_attributes(attributes = nil)
    if attributes.nil? || attributes.empty? || self.class.native_attributes?(attributes)
      super(attributes)
    else
      translated_params = self.class.keyize_index_attributes(attributes, {
        :include_fact => true
      })
      super(translated_params)
    end
  end

  def where_conditions_from_params(filters)
    fact_table = self.class.to_s.underscore.pluralize
      filters = filters.split(",")
    conds = []
    hash = {}
    for i in 0..filters.size/2 - 1
      if !hash.keys.include?(filters.first)
        hash[filters.shift] = [filters.shift]
      else
        hash[filters.shift] << filters.shift
      end
    end

    conds << "#{fact_table}.start_time >= #{ActiveRecord::Base.quote_value(Time.parse(hash.delete("start_time").to_s).strftime(TIME_FORMAT))}"
    conds << "#{fact_table}.end_time <= #{ActiveRecord::Base.quote_value(Time.parse(hash.delete("end_time").to_s).strftime(TIME_FORMAT))}"

    hash.each { |dim,vals|
      pk_name = Dimension.business_index_dictionary[dim]
      s = " IN(" + vals.map { |v| Dimension.find_by_business_index(dim, v).id }.join(",") + ")"
      conds << pk_name.to_s + s
    }
    conds
  end

  def is_fact? ; true ; end

end
end
