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

    # filles fact aggregation (fa) with appropriate results based on a parsed
    # params hash (options)
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
      end
      
      # standard query
      fa.add(fact.find_by_sql(
        "SELECT #{columns.join(", ")}, SUM(#{metric}) as sum
          FROM #{metric.pluralize}
          WHERE #{options[:where].join(" AND ")}
          GROUP BY #{group_by_list.join(", ")}"
      ))

      if options[:all_total] == []
        return
      end
      # summary query
      query_arr = parse_agg_dimensions(options[:summarize], columns, group_by_list)
      for query in query_arr
        sql_string = "SELECT #{query[:cols].join(", ")}, #{query[:alls].join(", ")}, SUM(#{metric}) as sum
        FROM #{metric.pluralize}
        WHERE #{options[:where].join(" AND ")}"
        if query[:group_by_columns] != []
          sql_string.concat(" GROUP BY #{query[:group_by_columns].join(", ")}")
        end
        fa.add(fact.find_by_sql(sql_string))
      end

      fa.adjust_time_zone(options[:tz_offset])
    end
    
    # takes arrays of:
    # 1. dimensions to summarize
    # 2. columns (aliased where appropriate)
    # 3. columns on which to group (un aliased)
    # and returns an array of hashes, each representing one query and containing:
    # 1. the non-summary columns to select (:cols)
    # 2. the summary columns to select (:alls)
    # 3. the columns on which to group (:group_by_columns)
    def parse_agg_dimensions(summarize_dims, columns, group_by_list)
      query_arr = []
      num_of_summarized_dims = summarize_dims.size
      i = 0
      for num_to_take in 1..num_of_summarized_dims
        combos = choose(summarize_dims, num_to_take)
        for combo in combos
          query_arr[i] = Hash.new
          query_arr[i][:cols] = columns.reject { |e| keyize_indices(combo).member?(e) }
          query_arr[i][:alls] = allize(combo)
          query_arr[i][:group_by_columns] = group_by_list.reject { |e| keyize_indices(combo).member?(e) }
          i += 1
        end
      end
      query_arr
    end
    
    # takes array of business columns and returns SQL which will select the 
    # associated primary key with the (string) value 'all'
    def allize(collumns_for_all)
      arr = []
      for col in collumns_for_all
        arr << "'all' as #{keyize_indices(col)}"
      end
      arr
    end
    
    # n choose k function for arrays. returns all combinations of k
    # elements from array n
    def choose(n, k)
      return [[]] if n.nil? || n.empty? && k == 0
      return [] if n.nil? || n.empty? && k > 0
      return [[]] if n.size > 0 && k == 0
      c2 = n.clone
      c2.pop
      new_element = n.clone.pop
      choose(c2, k) + append_all(choose(c2, k-1), new_element)
    end

    def append_all(lists, element)
      lists.map { |l| l << element }
    end

    def is_additive?
      true
    end
  end

  module InstanceMethods
  end

end
