module UniqueFactBehaviors 

  def self.included(base)
    base.class_eval do
      def self.acts_as_unique_fact
        extend FactBehaviors::ClassMethods
        include FactBehaviors::InstanceMethods
        extend ClassMethods
        include InstanceMethods
      end
    end
  end

  module ClassMethods

    def aggregate(fa, options = {})
      # ensure that we're grouping on at least one time attribute
      if !options[:group_by].include?("start_time") && !options[:group_by].include?("end_time")
          raise RuntimeError, "unique metrics must be grouped on either start or end time"
      end
      
      fact_table = self.to_s.underscore.pluralize
      where_list = self.new.where_conditions_from_params(options[:where])
      group_by_list = keyize_indices(options[:group_by]).map do |idx|
        "#{fact_table}.#{idx}"
      end
      column_aliases = {}
      parse_frequency_for_grouping(fact_table, options[:frequency], group_by_list, column_aliases)
      parse_frequency_for_filtering(options[:frequency], where_list)
      parse_summarize(options[:summarize], where_list)

      columns = group_by_list.map do |expr|
        if aliased = column_aliases[expr]
          "#{expr} as #{aliased}"
        else
          expr
        end
      end
      # deal with joined dimensions
      from_clause = ""
      handle_joined_dimensions(from_clause, columns, group_by_list, options[:group_by])

      fa.add(self.find_by_sql(
        "SELECT #{columns.join(", ")}, SUM(#{fact_table.singularize}) as sum
        FROM #{from_clause}
        WHERE #{where_list.join(" AND ")}
        GROUP BY #{group_by_list.join(", ")}"
      ))
    end

    def parse_summarize(options, where_list)
      for dimension in options
        where_list << "ISNULL(#{keyize_indices(dimension)})"
      end
    end

    def parse_frequency_for_filtering(frequency, where_list)
      case frequency
      when "hour"
        where_list << ["duration_in_minutes = 60"]
      when "day"
        where_list << ["duration_in_minutes = 1440"]
      when "week"
        where_list << ["duration_in_minutes = 10080"]
      when "month"
        # TODO: not positive this is the way we want to handle this
        where_list << ["duration_in_minutes > 10080"]
      when nil
        raise ArgumentError, "Frequency must be given in current implementation"
      else
        raise ArgumentError, "Unknown frequency: #{options[:frequency]}"
      end
    end

    def is_additive?
      false
    end
  end

  module InstanceMethods
  end

end
