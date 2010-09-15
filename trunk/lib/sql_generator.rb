module SqlGenerator
  class MySQL
    def date_from_datetime(expr)
      "date(#{expr})"
    end
    
    def hour_from_datetime(expr)
      "hour(#{expr})"
    end
  end
  
  class PostgreSQL
    def date_from_datetime(expr)
      "(#{expr})::date"
    end
    
    def hour_from_datetime(expr)
      "date_part('hour', (#{expr})::timestamp)"
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
  end
end
