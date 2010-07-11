# Ruote does not have explicit parameter passing to participants
# or returning values from them. Instead variables are put into
# workitem.fields hash where they may be read or written at will.
#
# This free for all approach is prone to errors, both spelling
# and logic. InputFields and Output classes here enforce
# separation between inputs and outputs to participants.
# Participants must enumerate all inputs they want to use;
# accessing an undeclared input is an error. Participants place
# output into appropriately designated output field.
#
# Unfortunately this separation requires creation of glue
# participants whose sole job is to copy variables from output
# fields into input fields; the benefit however is that all other
# participants are more generic and hopefully easier to develop
# and understand.

# Raised when a participant is invoked and not all of fields
# declared in :input option are present in workitem['input'].
class MissingInput < StandardError
end

# Raised when a participant attempts to access an input field
# that was not declared in :input or :optional_input option.
class KeyNotAllowed < StandardError
end

# Wrapper for input parameters.
#
# Enforces the policy requiring participants to declare which
# input parameters they accept - constructor takes a hash
# of parameters together with a list of keys which will be
# retrievable.
#
# InputFields supports indifferent access to parameters.
class InputFields
  # Creates an instance of InputFields that would allow
  # accessing keys listed in allowed_keys of hash hash.
  def initialize(allowed_keys, hash)
    @allowed_keys = allowed_keys
    if hash.nil?
      @hash = {}
    else
      @hash = hash.stringify_keys
    end
  end
  
  # If key is in the list of allowed keys passed to constructor,
  # returns a value for the key; otherwise raises KeyNotAllowed
  # exception.
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
  
  # Returns the data hash. Both keys and values of the hash
  # may have been modified since InputFields construction.
  def to_hash
    @hash.to_hash
  end
  
  # Merges other_hash into data hash of this instance.
  def merge(other_hash)
    @hash.to_hash.dup.update(other_hash.stringify_keys)
  end
end

# Wrapper for participants' results.
#
# Two types of results are supported: a single value or a hash.
# A participant may write the results in either form, but
# reading the results requires accessing them in the same
# way that they were written.
#
# Most participants write output (once), and do not read it.
# The usual exception is glue participants which read output
# and write to input fields.
class Output
  def initialize(hash=nil)
    if hash
      hash = hash.to_options
    else
      hash = {}
    end
    @fields, @value = hash[:fields], hash[:value]
  end
  
  # Writes value as output.
  #
  # Value must be json-serializable.
  def value=(value)
    @fields, @value = nil, value
  end
  
  # Writes fields as output.
  #
  # fields must be a hash and json-serializable.
  def fields=(fields)
    @fields, @value = fields, nil
  end
  
  # Retrieves output value.
  #
  # If output was set to a hash, raises ArgumentError.
  def value
    if value?
      @value
    else
      raise ArgumentError, "Output is fields but value requested"
    end
  end
  
  # Retrieves output hash.
  #
  # If output was set to a value, raises ArgumentError.
  def fields
    if fields?
      @fields
    else
      raise ArgumentError, "Output is value but fields requested"
    end
  end
  
  # Returns true if output was set to a value.
  def value?
    @fields.nil?
  end
  
  # Returns true if output was set to a hash.
  def fields?
    !@fields.nil?
  end
  
  # Converts Output instance to a hash suitable for placement into
  # workitem.fields.
  def to_hash
    if value?
      {:value => @value}
    else
      {:fields => @fields}
    end
  end
end

class Parameters
  attr_reader :workitem, :input, :output, :participant
  
  def initialize(workitem, input, output, participant)
    @workitem, @input, @output, @participant = workitem, input, output, participant
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
        input.update(workitem.fields['params'])
        input = InputFields.new(allowed_keys, input)
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
        @params = Parameters.new(workitem, input, output, self)
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
