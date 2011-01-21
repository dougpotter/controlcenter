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
    ['Unique Click Count', 'unique_click_count'],
    ['Unique Impression Count', 'unique_impression_count'],
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
    options_from_collection_for_select(@partners, :partner_code, :partner_code_and_name, params[:partner_code].map {|a| a.to_i})
  end

  def options_for_creative_select
    options_from_collection_for_select(@creatives, :creative_code, :creative_code, params[:creative_code])
  end

  def options_for_campaign_select
    options_from_collection_for_select(@campaigns, :campaign_code, :campaign_code, params[:campaign_code])
  end

  def options_for_ad_inventory_source_select
    options_from_collection_for_select(@ad_inventory_sources, :ais_code, :ais_code, params[:ais_code])
  end

  def options_for_audience_select
    options_from_collection_for_select(@audiences, :audience_code, :audience_code, params[:audience_code])
  end

  def options_for_media_purchase_method_select
    options_from_collection_for_select(@media_purchase_methods, :mpm_code, :mpm_code, params[:mpm_code])
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
