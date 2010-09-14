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
    options_from_collection_for_select(@partners, "id", "name", @partner)
    options_for_select(partners)
  end
  
  def options_for_creative_select
    options_for_select(creatives)
  end
  
  def options_for_campaign_select
    options_from_collection_for_select(@campaigns, "id", "campaign_code", @campaign)
    options_for_select(campaigns)
  end
  
  def all_filter_option
    "<option value=\"\">All</option>"
  end
  
  def partners
    [
      ['Partner 1', 1],
      ['Partner 2', 2],
    ]
  end
  
  def creatives
    [
      ['Creative 1', 1],
      ['Creative 2', 2],
    ]
  end
  
  def campaigns
    [
      ['Campaign 1', 1],
      ['Campaign 2', 2],
    ]
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
