module LandingPagesHelper
  FREQUENCIES = [
    ['Hourly', 'hourly'],
    ['Daily', 'daily'],
    ['Weekly', 'weekly'],
    ['Monthly', 'monthly'],
  ]
  
  METRICS = [
    ['Click Count', 'clicks'],
    ['Impression Count', 'impressions'],
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
  
  def all_filter_option
    "<option value=\"\">All</option>"
  end
  
  def dimensions
    [
      # label, name, form_tag_name
      ['Partner', 'partner', 'partners'],
      ['Creative', 'creative', 'creatives'],
      ['Campaign', 'campaign', 'campaigns'],
    ]
  end
end
