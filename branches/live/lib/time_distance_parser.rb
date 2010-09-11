class TimeDistanceParser
  class << self
    # Parses a time in str as a time distance comprising of value and unit.
    # Value may be integer or floating-point.
    # Unit may be seconds, minutes, hours, days, weeks, months or years.
    # Months are assumed to comprise 30 days, and years 365 days.
    # A unique prefx of each unit is acceptable.
    # Examples:
    #
    # 2s => 2 seconds
    # 1.5m => error - ambiguous
    # 1.5min => 1.5 minutes => 90 seconds
    # 3 day => 3 days => 259200 seconds
    def parse(str)
      unless str =~ /\A(\d+(?:\.\d+)?)\s*(\w+)\Z/
        raise ArgumentError, "Bad time distance: #{str}"
      end
      
      value, unit = $1, $2
      value = value.to_f
      unit = $2.downcase
      case unit
      when 's', 'se', 'sec', 'seco', 'secon', 'second', 'seconds'
        factor = 1
      when 'm'
        raise ArgumentError, "Please specify mo for months or mi for minutes: #{str}"
      when 'mi', 'min', 'minu', 'minut', 'minute', 'minutes'
        factor = 60
      when 'h', 'ho', 'hou', 'hour', 'hours'
        factor = 3600
      when 'd', 'da', 'day', 'days'
        factor = 86400
      when 'w', 'we', 'wee', 'week', 'weeks'
        factor = 604800
      when 'mo', 'mon', 'mont', 'month', 'months'
        # 30 day months
        factor = 2592000
      when 'y', 'ye', 'yea', 'year', 'years'
        # 365 day years
        factor = 31536000
      else
        raise ArgumentError, "Unknown unit: #{unit} in #{str}"
      end
      
      value *= factor
      int_value = value.to_i
      if int_value.to_f == value
        int_value
      else
        value
      end
    end
  end
end
