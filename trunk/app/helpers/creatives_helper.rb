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

  def image_tag_for_show(creative)
    case creative.creative_size.common_name
    when "Medium Rectangle"
      image_tag creative.image.url, :width => 100
    when "Leaderboard"
      image_tag creative.image.url, :height => 58
    when "Skyscraper"
      image_tag creative.image.url, :width => 66
    end
  end
end
