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

      metric = options[:fact]
      fact = Object.const_get(metric.classify)

      # check to see if we're grouping on valid dimensions
      valid_dimensions = fact.new.attributes.keys
      for dim in options[:group_by]
        if !valid_dimensions.include?(Dimension.keyize_indices(dim)[0].to_s) && dim != 'end_time' && dim != 'start_time'
          #raise RuntimeError, "cannot group #{fact.to_s} by #{dim}"
          render :text => nil, :status => 422
        end
      end

      where_list = fact.new.where_conditions_from_params(options[:where])
      group_by_list = keyize_indices(options[:group_by])
      column_aliases = {}
      parse_frequency_for_grouping(options[:fact].pluralize, options[:frequency], group_by_list, column_aliases)
      parse_frequency_for_filtering(options[:frequency], where_list)
      parse_summarize(options[:summarize], where_list)

      columns = group_by_list.map do |expr|
        if aliased = column_aliases[expr]
          "#{expr} as #{aliased}"
        else
          expr
        end
      end.join(', ')

      fa.add(fact.find_by_sql(
        "SELECT #{columns}, SUM(#{metric}) as sum
        FROM #{metric.pluralize}
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
