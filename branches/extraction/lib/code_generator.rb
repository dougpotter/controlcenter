module CodeGenerator
  def generate_unique_code(model_class, field_name, options={})
    code = loop do
      if block_given?
        code = yield
      else
        code = generate_code(options)
      end
      if options[:reject_if]
        next if options[:reject_if].call(code)
      end
      break code unless model_class.send("find_by_#{field_name}", code)
    end
  end
  module_function :generate_unique_code
  
  def generate_code(options)
    code = if options[:length]
      (1..options[:length]).to_a.map do
        generate_symbol(options)
      end
    end.join('')
    if options[:type]
      code = options[:type].new(code)
    end
    if options[:transform]
      code = options[:transform].call(code)
    end
    return code
  end
  module_function :generate_code
  
  def generate_symbol(options)
    # TODO not terribly efficient to split here
    options[:alphabet].split('').choice
  end
  module_function :generate_symbol
end
