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
    %w(campaign_management audiences partners ad_inventory_sources creatives).include?(controller.controller_name)
  end

  def all_option
    "<option value=''>All</option>"
  end

  def table_generator(collection, header_names, fields, class_name, width)
    return "" unless collection.any?
    table_str = ""
    table_str += "<table id=\"" + class_name + "\" class=\"" + class_name + "\" width=\"" + width + "\">\n"
    table_str += "\t<thead>\n"
    table_str += "\t\t<tr>\n"
    header_names.each do |name|
      table_str += "\t\t\t<th>"
      table_str += name
      table_str += "</th>\n"
    end
    table_str += "\t\t</tr>\n"
    table_str += "\t</thead>\n"
    table_str += "\t<tbody>\n"
    collection.each do |col|
      table_str += "\t\t<tr>\n"
      fields.each do |name|
        table_str += "\t\t\t<td>\n"
        table_str += link_to(col[name].to_s, edit_audience_path(col.id))
        table_str += "\t\t\t</td>\n"
      end
      table_str += "\t\t</tr>\n"
    end
    table_str += "\t</tbody>\n"
    table_str += "</table>\n"
  end
end
