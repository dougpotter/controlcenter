class UniqueFact < Fact
  include UniqueFactBehaviors
  acts_as_unique_fact
end
