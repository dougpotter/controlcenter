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
    else
      []
    end
    
    # TODO: DRY!!! (See lib/fact_behaviors.rb)
    frequency_attribute_set = case options[:frequency]
    when "hour" then
      [ "DATE(start_time)", "HOUR(start_time)" ]
    when "day" then
      [ "DATE(start_time)" ]
    when "week" then
      [ "DATE_SUB(DATE(start_time), INTERVAL (DAYOFWEEK(start_time) - 1) DAY)" ]
    else
      []
    end
    
    rows << (
      options[:dimensions] && options[:facts] ?
      options[:dimensions] + frequency_name_set + options[:facts] :
      @observations[0].attributes.keys
    )
    row_hash = {}
    column_sets = []
    for fact in @observations
      fact_value = fact.attributes["SUM(#{fact.class.name.to_s.underscore})"]
      if options[:dimensions] && options[:facts]
        dim_array = options[:dimensions].collect { |dim| fact.send(dim) } +
          frequency_attribute_set.collect { |attrib| fact.attributes[attrib] }
        row_hash[dim_array] ||= []
        options[:facts].each_with_index do |fact_name, idx|
          row_hash[dim_array][idx] ||= fact.attributes["SUM(#{fact_name.to_s})"]
        end
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
