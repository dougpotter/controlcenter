class WorkflowRunner
  attr_reader :logger
  
  def run(params)
    @logger = create_logger(params)
    if @logger
      # need to save this before running the workflow because the workflow
      # may override process title
      @script_name = File.basename($0)
      
      log_marker("#{self.class.name} run started at #{Time.now}")
    end
    
    default_params = HashWithIndifferentAccess.new(:logger => @logger)
    params = default_params.update(params)
    perform(params)
    log_marker("#{self.class.name} run finished successfully at #{Time.now}")
    0
  rescue Exception => exc
    raise if Interrupt === exc || SystemExit === exc
    rv = handle_exception(exc)
    log_marker("#{self.class.name} run died at #{Time.now}")
    rv
  end
  
  private
  
  def create_logger(options)
    if (path = options[:debug_output_path]) && path != '-'
      Logger.new(path)
    else
      nil
    end
  end
  
  def handle_exception(exc)
    forward_unhandled_exception(exc)
    1
  end
  
  def forward_unhandled_exception(exc, options={})
    options = {
      :cc_logger => @logger,
      :progname => @script_name,
    }.update(options)
    ConsoleUi.handle_unhandled_exception(exc, options)
  end
  
  def report_error(message)
    STDERR.puts(message)
    if @logger
      @logger.error(@script_name) { message }
    end
  end
  
  def log_marker(message)
    if @logger
      @logger.info(@script_name) do
        message
      end
    end
  end
end
