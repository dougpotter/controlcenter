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

      if !options[:group_by].include?("start_time") 
        if !options[:group_by].include?("end_time")
          raise RuntimeError, "unique metrics must be gropued on either start or end time"
        end
      end

      where_list = options[:where]
      group_by_list = keyize_indices(options[:group_by])
      column_aliases = {}
      
      parse_frequency_for_grouping(options[:frequency], group_by_list, column_aliases)
      parse_frequency_for_filtering(options[:frequency], where_list)

      metric = options[:fact]
      fact = Object.const_get(metric.classify)
      columns = group_by_list.map do |expr|
        if aliased = column_aliases[expr]
          "#{expr} as #{aliased}"
        else
          expr
        end
      end.join(', ')
      debugger
      fa.add(fact.find_by_sql(
        "SELECT #{columns}, SUM(#{metric}) as sum
        FROM #{metric.pluralize}
        WHERE #{where_list.join(" AND ")}
        GROUP BY #{group_by_list.join(", ")}"
      ))
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
