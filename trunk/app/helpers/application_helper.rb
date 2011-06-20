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

  def id_if_exists(model)
    begin
      id = model.id
    rescue RuntimeError
      id = nil
    end
    return id
  end
  
  def clear(how=:both, content=nil)
    if content == :br
      content = "<br />"
    elsif content == :span
      content = "<span />"
    end
    content_tag(:div, content, :style => "clear:#{how}")
  end

  def notice_that_fades(txt)
    "<div id=\"notice\">#{txt}</div><script type=\"text/javascript\">" +
    "window.addEvent('domready', function() {" +
    "(function() {" +
    "new Fx.Tween($('notice'), { property: 'opacity' }).start(0) }" +
    ").delay(3000);})</script>"
  end

  def audience_source_section_builder(campaign_types, f)
    forms_markup = []
    for campaign_type in campaign_types
      campaign_type_str = campaign_type.class.to_s
      markup_for_this_type = 
        (render(
          "/audiences/form_for_#{campaign_type_str.underscore}", 
          :f => f)
        ).inspect
      forms_markup << "\'#{campaign_type_str}\':#{markup_for_this_type}"
    end
    forms_markup_js = "var forms_markup = { #{forms_markup.join(',')} };"

    javascript_tag "#{forms_markup_js} function updateSourceSection(sourceType)"+
      "{ $('audience_source_section').set('html', forms_markup[sourceType]); }"
  end
end
