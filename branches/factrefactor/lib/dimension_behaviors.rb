module DimensionBehaviors

  def self.included(base)
    base.class_eval do

      def self.acts_as_dimension
        extend  ClassMethods
        include InstanceMethods
      end

    end
  end

  module ClassMethods
    # Class methods go here
    
    def model_dimensions
      ["campaign", "ad_inventory_source", "creative", "partner", "media_purchase_method"]
    end
  end

  module InstanceMethods
    def self.included( base )
      # Method statements go here; e.g.:
      #validates_presence_of :start_time

    end

    # Instance methods go here
  end

end
