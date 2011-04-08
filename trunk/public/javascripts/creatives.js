var root_url_regex = /((.*?)\/){3}/;
var campaign_form_url = location.href.match(root_url_regex)[0] +
"campaigns/options_filtered_by_partner?partner_id="

var injectFileField = function() {
  var creative_image_upload_element = $('creative_image');
  var file_upload_element = new Element('input', {
    id: "creative_image",
    name: "creative[image]",
    size: "30",
    type: "file"
  })
  $('creative_image').set('text','');
  $('creative_image').adopt(file_upload_element);
}

// filter campaigns by partner
window.addEvent('domready', function() {
  $('creative_partner').addEvent('change', function() {
    var partner_id = $('creative_partner').getProperty('value');
    var request = new Request.HTML({
      url: campaign_form_url + partner_id,
      method: 'get',
      update: $('creative_campaigns')
    })

    request.send();
  })
})
