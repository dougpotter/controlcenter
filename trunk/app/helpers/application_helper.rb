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
    rescue 
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

  # creative must be an array containing one creative
  def creative_form_builder(new_campaign, new_creative)
    form_template = ""
    fields_for :campaign, new_campaign do |campaign_form|
      campaign_form.fields_for :creatives, new_creative do |creative_form|
        form_template = (render "/creatives/form_without_line_item", :creative_fields => creative_form, :creative_number => 0, :creative => new_creative).inspect
      end
    end

    js_string = <<-eos
      function insertCreativeForm() { 
        var formIndex = 0;
        if ($$('.creative_form_without_line_item').length != 0) {
          formIndex = 
            $$('.creative_form_without_line_item').getLast().get('data-number')
        }
        var form_markup = setNestedFormIndex(#{form_template}, formIndex);
        var el = new Element('div').set('html', form_markup).getFirst();
        el.set('style', 'visibility:hidden;');
        $('add_creative_link').grab(el, 'before'); 
        setCreativeCode(formIndex, \"#{creative_code_url}\");
        el.set('style', 'visibility:visible;');
      };
    eos
    return javascript_tag "#{js_string}"
  end

  # constructs div just like error message div from error_messages_for except it is
  # for errors on the object passed in
  def error_messages_on(object)
    if object
      content_tag :div, { :class => "errorExplanation", :id => "errorExplanation"} do
        content_tag(:h2, "#{object.class} did not save") +
        content_tag(:p, "There were problems with the following fields") +
        content_tag(:ul) do
          for message in object.errors.full_messages
            content_tag(:li, message)
          end
        end
      end
    end
  end

  def nested_model_form_builder(context, model_str)
    form_markup = ""
    model_sym = model_str.to_sym
    model_plural_sym = model_str.pluralize.to_sym
    model_object = ActiveRecord.const_get(model_str.classify).new
    context_string = ""
    context.fields_for model_plural_sym, model_object do |new_context|
      context_string = new_context.object_name[0..-4]
      form_markup = escape_javascript(
        render :partial =>  
          "#{model_str}_fields", 
            :locals => { 
              :f => context,  
              :form_index => 1,  
              model_sym => new_context
      })
    end

    javascript = javascript_tag(
      <<-eos
      window.addEvent('domready', function() {
        $('add_action_tag').addEvent('click', function(e) {
          e.stop();
          appendNestedForm({
            modelName: "#{model_str}",
            modelNamePlural: "#{model_str.pluralize}",
            contextString: "#{context_string}",
            formMarkup: "#{form_markup}", 
            sidUrl: "#{sid_url}"
          });
        }); 
      })
      eos
    )
    return javascript
  end
end
