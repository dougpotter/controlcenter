module SqlGenerator
  class MySQL
    def date_from_datetime(expr)
      "date(#{expr})"
    end
    
    def hour_from_datetime(expr)
      "hour(#{expr})"
    end
    
    def beginning_of_week_from_datetime(expr)
      "DATE_SUB(DATE(#{expr}), INTERVAL (DAYOFWEEK(#{expr}) - 1) DAY)"
    end

    def beginning_of_month_from_datetime(expr)
      "DATE_SUB(DATE(#{expr}), INTERVAL (DAYOFMONTH(#{expr}) - 1) DAY)"
    end
    
    def cast_to_int(expr)
      "convert((#{expr}), signed integer)"
    end
  end
  
  class PostgreSQL
    def date_from_datetime(expr, options)
      "(#{expr})::date"
    end
    
    def hour_from_datetime(expr, options)
      "date_part('hour', (#{expr})::timestamp)"
    end
    
    def beginning_of_week_from_datetime(expr, options)
      # Note: on postgres sunday is day 0
      "(#{expr})::date - date_part('dow', (#{expr})::date)::integer"
    end

    def beginning_of_month_from_datetime(expr, options)
      # Note: on postgres first day of the month is 1
      "(#{expr})::date - date_part('day', (#{expr})::date)::integer + 1"
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
