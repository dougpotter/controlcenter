require 'faster_csv'

class FactAggregation 
  attr_accessor :facts

  def add(fact_arr)
    @facts << fact_arr
    @facts.flatten!
  end

  # adjust times by given offset (offset in format +/-0000)
  def adjust_time_zone(offset)
    offset_in_seconds = offset.to_i / 100 * 60
    for fact in @facts
      if fact.has_attribute?("end_time")
        fact.end_time += offset_in_seconds
      end
      if fact.has_attribute?("start_time")
        fact.start_time += offset_in_seconds
      end
    end
  end

  def to_csv
    rows = []
    rows << @facts[0].attributes.keys
    for fact in @facts
      rows << fact.attributes.values.map { |a| 
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
    @facts = []
  end
end
