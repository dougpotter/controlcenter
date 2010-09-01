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
    HANDLE_TO_FK = {"campaign_code" => "campaign_id", "ais_code" => "ad_inventory_source_id", "creative_code" => "creative_id", "partner_code" => "partner_id", "media_purchase_code" => "media_purchase_id"}
    FK_TO_HANDLE = {"campaign_id" => "campaign_code", "ad_inventory_source_id" => "ais_code", "creative_id" => "creative_code", "partner_id" => "partner_code", "media_purchase_id" => "media_purchase_code"}
    # Class methods go here
    
    def model_dimensions
      ["campaign", "ad_inventory_source", "creative", "partner", "media_purchase_method"]
    end

    def translate_fks(attributes)
      handleized = []
      for attribute in attributes
        if FK_TO_HANDLE.keys.member?(attribute)
          handleized << FK_TO_HANDLE[attribute]
        else 
          handleized << attribute
        end
      end
      handleized
    end

    def handle_to_fk(handle)
      HANDLE_TO_FK[handle]
    end

    def id_from_handle(handle, handle_value)
      if handle == "ais_code"
        id = AdInventorySource.find_by_ais_code(handle_value).id
      else
        fact = ActiveRecord.const_get(handle[0..-6].classify)
        find_string = "SELECT * FROM #{fact.to_s.underscore.pluralize} WHERE ? = ?"
        id = fact.find_by_sql(find_string, handle, handle_value).id
      end
      debugger
      return id
    end
  end

  module InstanceMethods
    def self.included( base )
      # Method statements go here; e.g.:

    end

    # Instance methods go here
  end

end
