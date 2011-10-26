class Dimension
  include DimensionBehaviors
  acts_as_dimension
  
end

# Force load dimension models
# TODO: Write rake task to preload necessary dictionaries
%w{
  ad_inventory_source audience campaign creative media_purchase_method
  partner
}.each do |rbfile|
  require rbfile
end

