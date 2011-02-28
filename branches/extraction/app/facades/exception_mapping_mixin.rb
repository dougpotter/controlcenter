module ExceptionMappingMixin
  private
  
  def map_exceptions(exception_map, url)
    begin
      yield
    rescue Exception => original_exc
      exception_map.each do |from_cls, to_cls|
        if original_exc.is_a?(from_cls)
          if to_cls.is_a?(Proc)
            to_cls.call(original_exc, url)
          else
            convert_and_raise(original_exc, to_cls, url)
          end
        end
      end
      
      # not mapped, raise original exception
      raise
    end
  end
  
  def convert_and_raise(original_exc, converted_cls, url, extra_options={})
    new_message = "#{original_exc.message} (#{original_exc.class})"
    options = {
      :url => url,
      :original_exception_class => original_exc.class,
    }.update(extra_options)
    exc = converted_cls.new(new_message, options)
    exc.set_backtrace(original_exc.backtrace)
    raise exc
  end
end
