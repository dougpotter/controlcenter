require 'dimension_behaviors'

ActiveRecord::Base.class_eval do
   include DimensionBehaviors
end
