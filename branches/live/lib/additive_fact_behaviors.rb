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
      fact_table = self.to_s.underscore.pluralize
      group_by_list = keyize_indices(options[:group_by]).map do |idx|
        "#{fact_table}.#{idx}"
      end
      column_aliases = {}
      parse_frequency_for_grouping(fact_table, options[:frequency], group_by_list, column_aliases)
      columns = group_by_list.map do |expr|
        if aliased = column_aliases[expr]
          "#{expr} as #{aliased}"
        else
          expr
        end
      end
      where_clause = self.new.where_conditions_from_params(options[:where])

      # ammend from_clause, columns, and group_by_list to account for selected
      # dimensions which do not appear in fact table (and therefore necessitate
      # a join)
      from_clause = ""
      handle_joined_dimensions(from_clause, columns, group_by_list, options[:group_by])


      # standard query
      fa.add(self.find_by_sql(
        "SELECT #{columns.join(", ")}, SUM(#{fact_table.singularize}) as sum
          FROM #{from_clause}
          WHERE #{where_clause.join(" AND ")}
          GROUP BY #{group_by_list.join(", ")}"
      ))

      if options[:all_total] == []
        return
      end


      query_arr = parse_agg_dimensions(options[:summarize], columns, group_by_list)
      for query in query_arr
        sql_string = "SELECT #{query[:cols].join(", ")}, #{query[:alls].join(", ")}, SUM(#{fact_table.singularize}) as sum
        FROM #{from_clause}
        WHERE #{where_clause.join(" AND ")}"
        if query[:group_by_columns] != []
          sql_string.concat(" GROUP BY #{query[:group_by_columns].join(", ")}")
        end
        fa.add(self.find_by_sql(sql_string))
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
    def self.included(base)
      base.validate :dimension_values
      base.validate :dimension_relationships
    end

    def dimension_values
      dimensions = self.attributes.keys.select do |dim|
        dim.match(/_id/)
      end

      nil_dims = dimensions.select { |dim|
        self.send(dim).nil?
      }

      for dim in nil_dims
        begin
          business_code = ActiveRecord.const_get(dim[0..-4].classify).business_code
        rescue
          # not an active record class yet (e.g. geography), can't have a code, so we just skip it
          next
        end

        code_at_initialize = attributes_on_initialize_as_hsh[business_code]
        if !code_at_initialize.nil?
          # code was provided, but not recognized, at initialize
          self.errors.add(dim, "was indeterminate at initialization because " +
                     "#{code_at_initialize.to_s} was unrecognized")
        end
      end
    end

    def dimension_relationships
      dimensions = self.attributes.keys.select do |dim|
        dim.match(/_id/)
      end

      dim_classes = dimensions.map { |d| 
        ActiveRecord.const_get(d.match(/(.+)_id/)[1].classify)
      }

      dim_classes_with_enforced_relationships = dim_classes.select { |dim|
        !dim.enforced_associations.empty?
      }

      for dim_class in dim_classes_with_enforced_relationships
        dim_red_name = dim_class.to_s.underscore + "_id"
        for association in dim_class.enforced_associations
          dim_blue_name = association.singularize + "_id"

          if self.attributes.member?(dim_blue_name)
            dim_red_value = self.send(dim_red_name).to_s
            dim_blue_value = self.send(dim_blue_name).to_s

            dim_red_string = dim_red_name + ":" + dim_red_value
            dim_blue_string = dim_blue_name + ":" + dim_blue_value
            cache_string = [ dim_red_string, dim_blue_string ].sort.join(":")

            self.errors.add_to_base("this is an unknown relationship: " + cache_string) unless Rails.cache.read(cache_string)
          end   
        end   
      end   
    end   
  end
end
