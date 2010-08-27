module RuoteGlobals
  mattr_accessor :host
  mattr_accessor :storage
  mattr_accessor :client
  mattr_accessor :workflows
  mattr_accessor :engine
  mattr_accessor :job_registry
  mattr_accessor :storage
  
  mattr_accessor :participants
  self.participants = {}
end
