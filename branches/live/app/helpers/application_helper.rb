# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_if here
    send("currently_#{here}?") ?
    "current" :
    ""
  end

  def currently_beacon_reports?
    %w{beacon_reports}.include? controller.controller_name
  end
  
end
