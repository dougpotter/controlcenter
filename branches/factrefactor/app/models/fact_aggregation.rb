require 'faster_csv'

class FactAggregation 
  attr_accessor :facts

  def add(fact_arr)
    @facts << fact_arr
    @facts.flatten!
  end

  def to_csv
    rows = []
    rows << @facts[0].attributes.keys
    for fact in @facts
      rows << fact.attributes.values.map { |f| f.to_s }
    end
    return rows
  end

  def initialize
    @facts = []
  end
end
