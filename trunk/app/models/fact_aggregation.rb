class FactAggregation 
  attr_accessor :fact_rows
  attr_accessor :fact_names

  def add(fact_arr, options = {})
    @observations.concat(fact_arr)
  end

  # adjust times by given offset (offset in format +/-0000)
  def adjust_time_zone(offset)
    offset_in_minutes = offset.to_i / 100 * 60
    for fact in @observations
      if fact.has_attribute?("end_time")
        fact.end_time += offset_in_minutes
      end
      if fact.has_attribute?("start_time")
        fact.start_time += offset_in_minutes
      end
    end
  end

  def to_csv(options = {})
    rows = []
    
    frequency_name_set = case options[:frequency]
    when "hour" then
      %w{ day hour }
    when "day" then
      %w{ day }
    when "week" then
      %w{ week }
    when "month" then
      %w{ month }
    else
      []
    end
    
    # Note: FactBehaviors' job is to alias the expressions to
    # correct column names
    frequency_attribute_set = case options[:frequency]
    when "hour" then
      [ 'date', 'hour' ]
    when "day" then
      [ 'date' ]
    when "week" then
      [ 'start_date' ]
    when "month" then
      [ 'start_date' ]
    else
      []
    end
    
    rows << (
      options[:dimensions] && options[:facts] ?
      options[:dimensions] + frequency_name_set + options[:facts] :
      @observations[0].attributes.keys
    )
    
    cache = BusinessIndexLookupCache.new

    row_hash = {}
    column_sets = []
    for fact in @observations
      fact_value = fact.attributes['sum']
      if options[:dimensions] && options[:facts]
        dim_array = options[:dimensions].collect { |dim|
          id_column = Dimension.business_index_dictionary[dim]
          if id_column
            if (id = fact.send(id_column)) != 0 && (id = fact.send(id_column)) != nil
              cache.resolve_code(id_column, id, dim)
            else
              'all'
            end
          else
            fact.send(dim)
          end
        } +
          frequency_attribute_set.collect { |attrib| fact.send(attrib) }
        row_hash[dim_array] ||= []
        row_hash[dim_array][options[:facts].index(fact.class.to_s.underscore)] ||= fact.attributes['sum']
      else
        column_sets << fact.attributes.values
      end
    end

    if options[:dimensions] && options[:facts]
      row_hash.each do |key, value|
        column_sets << key + value
      end
    end
        
    column_sets.each do |col_set|
      rows << col_set.map { |a| 
        if a.is_a?(Time)
          a.strftime("%Y-%m-%d  %H:%M:%S")
        else
          a.to_s 
        end
      }
    end
    
    return rows
  end

  def initialize
    @observations = []
    @fact_names = []
  end
end
