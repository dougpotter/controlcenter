var root_url_regex = /((.*?)\/){3}/;
var audience_source_form_url = location.href.match(root_url_regex)[0] + 
"audiences/audience_source_form?source=";

window.addEvent('domready', function() {

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
    var audience_type_selector = $('campaign_campaign_type');
    audience_type_selector.addEvent('change', function() {

      var audience_type= audience_type_selector.getSelected().getProperty('value');
      var campaign_code = $('campaign_campaign_code').getProperty('value');

      var req = new Request.HTML({
        url: audience_source_form_url + audience_type + '&campaign_code=' + campaign_code,
        method: 'get',
        update: $("audience_source_section"),
        onFailure: function(response) {
          if (response.status == 403) { 
            alert("Audience Source Error!\nCannot switch to type " + audience_type);
          }
        }
    });
    req.send();
  });
})
