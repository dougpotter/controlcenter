class AdditiveFact < Fact
  include AdditiveFactBehaviors
  acts_as_additive_fact
end
