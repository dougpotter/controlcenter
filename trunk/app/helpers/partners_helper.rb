module PartnersHelper
  def action_tag_form_builder(f)
    form_markup = escape_javascript(render :partial => "action_tag_fields", :locals => { :f => f, :form_index => 0 })

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
