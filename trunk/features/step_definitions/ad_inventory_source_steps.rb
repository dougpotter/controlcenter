When /^the following ad_inventory_sources:$/ do |aises|
  for ais in aises.hashes
    if !AdInventorySource.find_by_ais_code(ais[:ad_inventory_source])
      AdInventorySource.create!(ais)
    end
  end
end
