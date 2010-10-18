# should be required already but since we use exceptions require it here also
require 'optparse'

module WorkflowInvocation
  def check_extraction_options(options)
    if options[:discover] && options[:extract]
      raise OptionParser::ParseError, "--discover and --extract cannot be specified simultaneously"
    end
  end
  module_function :check_extraction_options
  
  def check_verification_options(options)
    unless options[:check_listing] || options[:check_consistency] ||
      options[:check_our_existence] || options[:check_their_existence]
    then
      options[:check_listing] = options[:check_consistency] =
        options[:check_our_existence] = options[:check_their_existence] = true
    end
  end
  module_function :check_verification_options
  
  def check_date(options)
    if date = options[:date]
      unless date =~ /\A\d{8}\Z/
        raise OptionParser::ParseError, "Invalid date value: #{date}"
      end
    else
      options[:date] = Time.now.strftime('%Y%m%d')
    end
  end
  module_function :check_date
  
  def check_hours(options)
    if options[:hours]
      begin
        options[:hours] = parse_hours_specification(options[:hours])
      rescue ArgumentError => e
        raise OptionParser::ParseError, e.message
      end
    end
  end
  module_function :check_hours
  
  def lookup_data_provider(name)
    data_provider = DataProvider.find_by_name(name)
    unless data_provider
      raise "Data provider #{name} not found, is database seeded?"
    end
    data_provider
  end
  module_function :lookup_data_provider
  
  def parse_hours_specification(hours)
    hours = hours.split(',').map do |hour|
      hour = hour.strip
      unless hour =~ /^\d\d?/
        raise ArgumentError, "Invalid hour value: #{hour}"
      end
      hour = hour.to_i
      if hour < 0 || hour > 23
        raise ArgumentError, "Hour value out of range: #{hour}"
      end
      hour
    end
  end
  module_function :parse_hours_specification
  
  def parse_source_specification(data_provider, source)
    if source
      if source.empty?
        raise OptionParser::ParseError, "Source is empty"
      end
      # need to check find_by_* arguments for being blank or empty
      channel = data_provider.data_provider_channels.find_by_name(source)
      if channel
        selected_channels = [channel]
      else
        raise OptionParser::ParseError, "Invalid source value: #{source}"
      end
    else
      selected_channels = data_provider.data_provider_channels.all(:order => 'name')
    end
  end
  module_function :parse_source_specification
end
