module SqlGenerator
  class MySQL
    def date_from_datetime(expr, options)
      "date(#{options[:fact_table]}.#{expr})"
    end
    
    def hour_from_datetime(expr, options)
      "hour(#{options[:fact_table]}.#{expr})"
    end
    
    def beginning_of_week_from_datetime(expr, options)
      "DATE_SUB(DATE(#{options[:fact_table]}.#{expr}), INTERVAL (DAYOFWEEK(#{options[:fact_table]}.#{expr}) - 1) DAY)"
    end

    def beginning_of_month_from_datetime(expr, options)
      "DATE_SUB(DATE(#{options[:fact_table]}.#{expr}), INTERVAL (DAYOFMONTH(#{options[:fact_table]}.#{expr}) - 1) DAY)"
    end
    
    def cast_to_int(expr)
      "convert((#{expr}), signed integer)"
    end
  end
  
  class PostgreSQL
    def date_from_datetime(expr, options)
      "(#{options[:fact_table]}.#{expr})::date"
    end
    
    def hour_from_datetime(expr, options)
      "date_part('hour', (#{options[:fact_table]}.#{expr})::timestamp)"
    end
    
    def beginning_of_week_from_datetime(expr, options)
      # Note: on postgres sunday is day 0
      "(#{options[:fact_table]}.#{expr})::date - date_part('dow', (#{options[:fact_table]}.#{expr})::date)::integer"
    end

    def beginning_of_month_from_datetime(expr, options)
      # Note: on postgres first day of the month is 1
      "(#{options[:fact_table]}.#{expr})::date - date_part('day', (#{options[:fact_table]}.#{expr})::date)::integer + 1"
    end
    
    def cast_to_int(expr)
      "(#{expr})::integer"
    end
  end
  
  if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
    @@impl = PostgreSQL.new
  else
    @@impl = MySQL.new
  end
  
  class << self
    def method_missing(meth, *args)
      @@impl.send(meth, *args)
    end
    
    def respond_to?(meth)
      super || @@impl.respond_to?(meth)
    end
  end
end
