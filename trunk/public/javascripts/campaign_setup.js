var root_url_regex = /((.*?)\/){3}/;
var audience_source_form_url = location.href.match(root_url_regex)[0] + 
"audiences/audience_source_form?source=";

window.addEvent('domready', function() {

    // handle visibility of refresh field and s3 bucket select
    function toggleVisibility(checkbox, target) {
      if (checkbox.checked) {
        $(target).setStyle('visibility', 'visible');
      }
      else {
        $(target).setStyle('visibility', 'hidden');
      }
    }

    function toggleOpacity(checkbox, target) {
      if (checkbox.checked) {
        $(target).setStyle('opacity', 0.6);
      }
      else {
        $(target).setStyle('opacity', 1);
      }
    }

    if ($('refresh_checkbox') != null) {
      $('refresh_checkbox').addEvent('click', function () {
        toggleVisibility($('refresh_checkbox'), $('s3_source_field_div'));
        toggleOpacity($('refresh_checkbox'), $('s3_source_select_div'));
      })
    }

    // attaches a funciton to the checkbox which changes visibility of the 
    // entry fields associated with that checkbox when the checkbox is clicked 
    // (fields appear when checkbox is checked and disappear when it is un-checked)
    function buildToggleEntryFunction(checkbox) {
      var ais = checkbox.value;
      var fields_class = "sync_rule_entry_boxes_" + ais;
      return function () {
        if (checkbox.checked) { 
          $(fields_class).setStyle('visibility', 'visible');
        }   
        else {
          $(fields_class).setStyle('visibility', 'hidden');
        } 
      }   
    }   

    // checkboxes for aises
    var checkboxes = $$('.sync_rule_ais');
    var num_checkboxes = checkboxes.length;

    // array for closed toggle entry functions
    var toggleEntryFunctions = new Array(num_checkboxes);

    // build toggle entry functions
    for (i = 0; i < num_checkboxes; i++) {
      toggleEntryFunctions[i] = buildToggleEntryFunction(checkboxes[i]);
    }   

    // attached toggle entry functions to click events for each checkbox
    for (i = 0; i < num_checkboxes; i++) {
      checkboxes[i].addEvent('click', toggleEntryFunctions[i]);
    } 

    // attach event listener audience type select which updates audience source
    // fields when appropriate
    var audience_type_selector = $('campaign_audience_attributes_audience_sources_attributes_0_type');

    if (audience_type_selector != null) {
      audience_type_selector.addEvent('change', function() { 
        updateSourceSection(audience_type_selector.value);
      });
    }
})
