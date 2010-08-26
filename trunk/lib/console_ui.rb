module ConsoleUi
  def handle_unhandled_exception(e, msg)
    puts msg || "Unhandled exception:"
    puts "#{e.class}: #{e.message}"
    puts '    in ' + e.backtrace.join("\n  from ")
    127
  end
  module_function :handle_unhandled_exception
end
