module AdditiveFactBehaviors 

  def self.included(base)
    base.class_eval do
      def self.acts_as_additive_fact
        extend FactBehaviors::ClassMethods
        include FactBehaviors::InstanceMethods
        extend ClassMethods
        include InstanceMethods
      end
    end
  end

  module ClassMethods
    def aggregate(fa, options = {})

      group_by_list = keyize_indices(options[:group_by])
      column_aliases = {}

      parse_frequency_for_grouping(options[:frequency], group_by_list, column_aliases)
      metric = options[:fact]
      fact = Object.const_get(metric.classify)
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
          WHERE #{options[:where].join(" AND ")}
          GROUP BY #{group_by_list.join(", ")}"
      ))
      fa.adjust_time_zone(options[:tz_offset])
    end

    def is_additive?
      true
    end
  end

  module InstanceMethods
  end

end
