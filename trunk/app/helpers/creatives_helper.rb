module CreativesHelper
  def image_tag_for_edit(creative)
    case creative.creative_size.common_name
    when "Medium Rectangle"
      image_tag creative.image.url, :width => 150
    when "Leaderboard"
      image_tag creative.image.url, :height => 80
    when "Skyscraper"
      image_tag creative.image.url, :width => 100
    end
  end

  def image_tag_for_thumb(creative)
    case creative.creative_size.common_name
    when "Medium Rectangle"
      image_tag creative.image.url, :width => 100
    when "Leaderboard"
      image_tag creative.image.url, :height => 32
    when "Skyscraper"
      image_tag creative.image.url, :width => 66
    end
  end

  def image_tag_for_campaign_show(creative)
    case creative.creative_size.common_name
    when "Medium Rectangle"
      image_tag creative.image.url, :width => 170
    when "Leaderboard"
      image_tag creative.image.url, :height => 32
    when "Wide Skyscraper"
      image_tag creative.image.url, :width => 40
    end
  end

  def image_tag_for_campaign_edit(creative)
    case creative.creative_size.common_name
    when "Medium Rectangle"
      image_tag creative.image.url, :width => 100
    when "Leaderboard"
      image_tag creative.image.url, :height => 32
    when "Wide Skyscraper"
      image_tag creative.image.url, :width => 25
    end
  end
end
