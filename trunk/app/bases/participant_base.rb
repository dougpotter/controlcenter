class MissingInput < StandardError
end

class KeyNotAllowed < StandardError
end

class InputFields
  def initialize(allowed_keys, hash)
    @allowed_keys = allowed_keys
    if hash.nil?
      @hash = {}
    else
      @hash = hash.stringify_keys
    end
  end
  
  def [](key)
    key = key.to_s
    if @allowed_keys.include?(key)
      @hash[key]
    else
      raise KeyNotAllowed, "Key #{key} not declared as input field"
    end
  end
  
  # assignment is used in glue participants, allow assigning to any key
  def []=(key, value)
    @hash[key] = value
  end
  
  def to_hash
    @hash.to_hash
  end
  
  def merge(other_hash)
    @hash.to_hash.dup.update(other_hash.stringify_keys)
  end
end

class LocalFields
end

class OutputFields
end

class Output
  def initialize(hash=nil)
    if hash
      hash = hash.to_options
    else
      hash = {}
    end
    @fields, @value = hash[:fields], hash[:value]
  end
  
  def value=(value)
    @fields, @value = nil, value
  end
  
  def fields=(fields)
    @fields, @value = fields, nil
  end
  
  def value
    if value?
      @value
    else
      raise ArgumentError, "Output is fields but value requested"
    end
  end
  
  def fields
    if fields?
      @fields
    else
      raise ArgumentError, "Output is value but fields requested"
    end
  end
  
  def value?
    @fields.nil?
  end
  
  def fields?
    !@fields.nil?
  end
  
  def to_hash
    if value?
      {:value => @value}
    else
      {:fields => @fields}
    end
  end
end

class Parameters
  attr_reader :workitem, :input, :locals, :output, :participant
  
  def initialize(workitem, input, local, output, participant)
    @workitem, @input, @local, @output, @participant = workitem, input, local, output, participant
  end
  
  def reply
    @participant.reply_to_engine(@workitem)
  end
  
  # ruote job id shortcut
  def rjid
    workitem.fei.wfid
  end
end

class ParticipantBase
  include Ruote::LocalParticipant
  
  def initialize(workitem, context)
    @workitem, @context = workitem, context
  end
  
  # Note: keys must be strings
  def validate_arguments(workitem, required_keys)
    fields = workitem.fields
    required_keys.each do |key|
      raise ArgumentError, "Missing required argument #{key}" unless fields[key]
    end
  end
  
  attr_reader :params, :workitem
  
  class << self
    # Available options:
    # :sync
    # :async
    # :input
    # :optional_input
    # :require_output_value
    def consume(name, options={}, &block)
      raise ArgumentError, "Participant method must specify :sync or :async" unless options[:sync] || options[:async]
      
      participant_name = "#{self.name.sub(/.*::/, '').sub(/Participant$/, '')}:#{name}"
      
      define_method("consume_#{name}") do
        allowed_keys = (options[:input] || []) + (options[:optional_input] || []).map { |key| key.to_s }
        if input = workitem.fields['input']
          input = input.with_indifferent_access
        else
          input = HashWithIndifferentAccess.new
        end
        input = InputFields.new(allowed_keys, input)
        local = LocalFields.new
        output = Output.new(workitem.fields['output'])
        
        if options[:input]
          options[:input].each do |key|
            unless input[key]
              raise ArgumentError, "Participant #{participant_name} was not given required input var: #{key}"
            end
          end
        end
        
        if options[:require_output_value]
          unless output.value?
            raise ArgumentError, "Output is not value"
          end
        end
        
        # todo: filter input according to options[:input]
        @params = Parameters.new(workitem, input, local, output, self)
        instance_eval(&block)
        
        workitem.fields['input'] = input.to_hash
        workitem.fields['output'] = output.to_hash
        
        params.reply if options[:sync]
      end
      
      participants = RuoteGlobals.participants
      participant_instance = ParticipantBuilder.build_participant(self, name)
      participants[participant_name] = participant_instance
    end
  end
  
  def reply(params)
  end
end

class ParticipantProxy
  include Ruote::LocalParticipant
  
  def initialize(cls, meth)
    @cls, @meth = cls, meth
  end
  
  def consume(workitem)
    @cls.new(workitem, context).send("consume_#{@meth}")
  end
  
  def cancel(fei, flavor)
    # ignore?
  end
end

class ParticipantBuilder
  class << self
    @@participant_cache = {}
    
    def build_participant(cls, meth)
      key = "#{cls}-#{meth}"
      part = @@participant_cache[key]
      unless part
        part = ParticipantProxy.new(cls, meth)
      end
      part
    end
  end
end
