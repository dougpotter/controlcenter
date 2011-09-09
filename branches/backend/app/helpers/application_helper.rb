# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  #include ActionController::UrlWriter
  def current_if here
    send("currently_#{here}?") ?
      "current" :
      ""
  end

  def currently_metric_reports?
    %w{landing_pages}.include? controller.controller_name
  end

  def currently_extraction_status?
    %w(extraction).include?(controller.controller_name)
  end

  def currently_campaign_management?
    %w(line_items campaign_management audiences partners ad_inventory_sources creatives campaigns).include?(controller.controller_name)
  end

  def currently_appnexus?
    %w(appnexus).include?(controller.controller_name)
  end

  def all_option
    "<option value=''>All</option>"
  end

  def none_option
    "<option value=''>-</option>"
  end
  
  def clear(how=:both, content=nil)
    if content == :br
      content = "<br />"
    elsif content == :span
      content = "<span />"
    end
    content_tag(:div, content, :style => "clear:#{how}")
  end
  
  def appnexus_sync_list_path(year, month)
    appnexus_sync_list_impl_path(year, sprintf('%02d', month))
  end
end
