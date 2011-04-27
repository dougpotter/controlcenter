require 'fact_behaviors'
require 'additive_fact_behaviors'
require 'unique_fact_behaviors'

ActiveRecord::Base.class_eval do
  include FactBehaviors
  include AdditiveFactBehaviors
  include UniqueFactBehaviors
end
