# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
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
    %w(campaign_management audiences).include?(controller.controller_name)
  end
end
