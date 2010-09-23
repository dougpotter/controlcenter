module LandingPagesHelper
  FREQUENCIES = [
    ['Hourly', 'hour'],
    ['Daily', 'day'],
    ['Weekly', 'week'],
    ['Monthly', 'month'],
  ]
  
  METRICS = [
    ['Click Count', 'click_count'],
    ['Impression Count', 'impression_count'],
    ['Conversion Count', 'conversion_count'],
    ['Unique Conversion Count', 'unique_conversion_count'],
    ['Unique Remote Placement Count', 'unique_remote_placement_count'],
    ['Unique View-Through Conversions', 'unique_view_through_conversion_count'],
  ]
  
  def options_for_frequency_select
    options_for_select(FREQUENCIES)
  end
  
  def options_for_metric_select
    options_for_select(METRICS)
  end
  
  def options_for_partner_select
    options_from_collection_for_select(@partners, :id, :partner_code_and_name)
  end
  
  def options_for_creative_select
    options_from_collection_for_select(@creatives, :id, :creative_code)
  end
  
  def options_for_campaign_select
    options_from_collection_for_select(@campaigns, :id, :campaign_code)
  end
  
  def options_for_ad_inventory_source_select
    options_from_collection_for_select(@ad_inventory_sources, :id, :ais_code)
  end
  
  def options_for_audience_select
    options_from_collection_for_select(@audiences, :id, :audience_code)
  end
  
  def options_for_media_purchase_method_select
    options_from_collection_for_select(@media_purchase_methods, :id, :mpm_code)
  end
  
  def all_filter_option
    "<option value=\"\">All</option>"
  end
  
  def dimensions
    [
      # label, name, form_tag_name
      ['Partner', 'partner', 'partner_code'],
      ['Creative', 'creative', 'creative_code'],
      ['Campaign', 'campaign', 'campaign_code'],
      ['AIS', 'ad_inventory_source', 'ais_code'],
      ['Audience', 'audience', 'audience_code'],
      ['MPM', 'media_purchase_method', 'mpm_code'],
    ]
  end
end
