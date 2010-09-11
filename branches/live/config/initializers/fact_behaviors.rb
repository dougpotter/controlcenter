require 'fact_behaviors'

ActiveRecord::Base.class_eval do
   include FactBehaviors
end
