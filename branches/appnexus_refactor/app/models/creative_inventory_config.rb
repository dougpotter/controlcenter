class CreativeInventoryConfig < ActiveRecord::Base
  belongs_to :creative
  belongs_to :campaign_inventory_config
end
