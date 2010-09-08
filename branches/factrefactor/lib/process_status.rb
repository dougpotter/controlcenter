# Keeps track of process status and updates process title ($0, see also
# setproctitle(3)).
#
# Process status is expected to consist of three parts:
#
# script: basename of the script being invoked, or a name of the overall
#         process executed otherwise (example: clearspring-extract).
# params: important parameters to the script currently being used
#         (example: view-us;20100523-0100 which is channel, date and hour
#         for clearspring extraction).
# action: what is currently being done (example: fetch http://host/path).
#
# ProcessStatus module will automatically set the process title if
# script is set. Setting params or action without setting script does not
# result in the process title being updated.
#
# ProcessStatus persists script, params and action internally so that
# changing action will update the process title (if script and params are set)
# using previously set values for script and params.
module ProcessStatus
  def set(options)
    StateManager.instance.set(options) do
      yield
    end
  end
  module_function :set
  
  class State
    attr_accessor :script
    attr_accessor :params
    attr_accessor :action
    
    def update(script, params, action)
      @script, @params, @action = script, params, action
    end
    
    def writable?
      !script.nil?
    end
    
    def write
      if script
        title = script
        if params
          title += ": #{params}"
          if action
            title += ": #{action}"
          end
        end
        
        $0 = title
        true
      else
        false
      end
    end
  end
  
  class StateManager
    class StackUnderflow < StandardError; end
    
    include Singleton
    
    def initialize
      @stack = []
      @state = State.new
      @initial_title = $0
    end
    
    def save
      @stack << @state.dup
    end
    
    def restore
      raise StackUnderflow if @stack.empty?
      @state = @stack.pop
    end
    
    def set(options)
      if options[:script]
        new_script = options[:script]
        new_params = new_action = nil
      else
        state = @state
        new_script = state.script
        new_params = state.params
        new_action = state.action
      end
      
      if options[:params]
        new_params = options[:params]
        new_action = nil
      end
      
      if options[:action]
        new_action = options[:action]
      end
      
      unless new_script
        new_params = nil
      end
      
      unless new_params
        new_action = nil
      end
      
      if block_given?
        save
        begin
          @state.update(new_script, new_params, new_action)
          @state.write
          yield
        ensure
          restore
          @state.write || write_initial
        end
      else
        @state.update(new_script, new_params, new_action)
        @state.write
      end
    end
    
    private
    
    def write_initial
      $0 = @initial_title
    end
  end
  
  def set_script(script_str)
    if block_given?
      set_field(:script, script_str) do
        yield
      end
    else
      set_field(:script, script_str)
    end
  end
  module_function :set_script
  
  def set_params(params_str)
    if block_given?
      set_field(:params, script_str, [:script]) do
        yield
      end
    else
      set_field(:params, script_str, [:script])
    end
  end
  module_function :set_params
  
  def set_action(action_str)
    if block_given?
      set_field(:action, script_str, [:script, :params]) do
        yield
      end
    else
      set_field(:action, script_str, [:script, :params])
    end
  end
  module_function :set_action
  
  private
  
  def set_field(field, value, dependent_fields=nil)
    state = State.instance
    if !block_given?
      state.send("#{field}=", value)
      state.write
    else
      old_value = state.send(field)
      if dependent_fields
        old_deps = {}
        dependent_fields.each do |field|
          old_deps[field] = state.send(field)
        end
      end
      
      state.send("#{field}=", value)
      state.write
      begin
        yield
      ensure
        state.send("#{field}=", old_value)
        if dependent_fields
          old_deps.each do |key, value|
            state.send("#{key}=", value)
          end
        end
        state.write!
      end
    end
  end
end
