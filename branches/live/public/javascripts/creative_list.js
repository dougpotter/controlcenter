var root_url_regex = /((.*?)\/){3}/;
var creative_index_url = location.href.match(root_url_regex)[0] + "creatives";

var update_creative_list_req = new Request.HTML({
  url: creative_index_url,
  method: 'get',
  onSuccess: function(txt){
    $('creatives').set('text', '');
    $('creatives').adopt(txt);
  },

  onFailure: function(){
    alert('Could not retrieve creatives');
  }
});

window.addEvent('domready', function(){
  $('campaign_partner_id').addEvent('change', function(){
    var partner_id = $('campaign_partner_id').getSelected().getProperty('value');
    update_creative_list_req.send({data: "partner_id=" + partner_id});
  });
});

var newCreativeForm = function() {
  var number_of_creatives = $$('.creative_form_without_line_item').length;
  var root_url_regex = /((.*?)\/){3}/;
  var new_creative_url = location.href.match(root_url_regex)[0] + "creatives/form_without_line_item?creative_number=" + number_of_creatives;
  var req = new Request.HTML({
    url: new_creative_url,
    method: 'get',
    append: $('new_creatives')
  });   
  req.send();
}

window.addEvent('domready', function() {
    var partner_id = $('campaign_partner_id').getSelected().getProperty('value');
    var campaign_code = $('campaign_campaign_code').getProperty('value');
    update_creative_list_req.send({data: "partner_id=" + partner_id + "&campaign_code=" + campaign_code});
  });
