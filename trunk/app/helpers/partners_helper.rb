module PartnersHelper
  def action_tag_form_builder(f, action_tag_for_form_builder)
    form_markup = ""
    f.fields_for :action_tags, ActionTag.new do |action_tag|
      form_markup = escape_javascript(
        render :partial => 
          "action_tag_fields", 
            :locals => { 
              :f => f, 
              :form_index => 0, 
              :action_tag => action_tag 
      })
    end

    javascript = javascript_tag(
      <<-eos
      window.addEvent('domready', function() {
        $('add_action_tag').addEvent('click', function(e) {
          e.stop();
          appendActionTagForm("#{form_markup}");
        }); 
      })
      eos
    )

    return javascript
  end
end
