module ConsoleUi
  def handle_unhandled_exception(exc, options={})
    text = options[:message] || "Unhandled exception:"
    text += "\n#{exc.class}: #{exc.message}"
    text += "\n    in " + exc.backtrace.join("\n  from ")
    puts text
    if logger = options[:cc_logger]
      logger.error(options[:progname]) do
        text
      end
    end
    127
  end
  module_function :handle_unhandled_exception
end
