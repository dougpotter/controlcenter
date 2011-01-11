namespace :dimension_cache do
  # seeds cache with dimension values in the format 
  # key => dimension_name:dimension_value 
  # value => true
  # 
  # for example
  # key => campaign_code:UCCO
  # value => true
  #
  # and seeds cache with dimension relationships in the format
  # key => dimension_one:dimension_one_value:dimension_two:dimension_two_value
  # value => true
  #
  # for example
  # key => campaign_code:UCCO:creative_code:wvf-234
  # value => true
  #
  # Notes:
  # - dimension_cache:seed deletes any content already in the cache
  desc "Seed cache with dimension values and relationships"
  task :seed => [ :environment, :reset ] do
    cache = Rails.cache

    known_dimensions = { "campaign" => "campaign_code", 
      "partner" => "partner_code", 
      "creative" => "creative_code", 
      "ad_inventory_source" => "ais_code", 
      "media_purchase_method" => "mpm_code",
      "audience" => "audience_code" }

    known_dimensions.each do |model_str,model_code|
      model_class = ActiveRecord.const_get(model_str.classify)
      known_values = model_class.all.map { |m| m.send(model_code) }
      for value in known_values
        cache.write(model_code.to_s + ":" + value.to_s, true)
      end
    end

    relationships = [ 
      [ :campaign, :ad_inventory_sources ],
      [ :campaign, :creatives ],
      [ :campaign, :line_item ] ] 
    codes = { 
      :ad_inventory_sources => :ais_code,
      :creatives => :creative_code,
      :line_item => :line_item_code }

    for campaign in Campaign.all
      campaign_code_value = campaign.campaign_code
      dim_one_component = "campaign_code:" + campaign_code_value.to_s
      relationships.each do |rel|
        business_index_name = codes[rel[1]]
        for relation in campaign.send(rel[1]).to_a
          business_index_value = relation.send(business_index_name).to_s
          dim_two_component = business_index_name.to_s + ":" + business_index_value.to_s
          puts dim_one_component + ":" + dim_two_component
          cache.write(dim_one_component + ":" + dim_two_component, true)
        end
      end
    end
  end

  desc "Delete contents of cache"
  task :reset => :environment  do
    Rails.cache.reset
  end
end
