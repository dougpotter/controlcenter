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
  var root_url_regex = /((.*?)\/){3}/;
  var new_creative_url = location.href.match(root_url_regex)[0] + "creatives/form_without_campaign";
  var req = new Request.HTML({
    url: new_creative_url,
    method: 'get',
    onSuccess: function(txt) {
      // inject new creative form
      $('new_creative_form').set('text', "");
      $('new_creative_form').adopt(txt);
      $('creative_submit').addEvent('click', function(event) {        
        event.stop();        
        $('new_creative').send();
        var partner_id = $('campaign_partner_id').getSelected().getProperty('value');
        var campaign_code = $('campaign_campaign_code').getProperty('value');
        update_creative_list_req.send({data: "partner_id=" + partner_id + "&campaign_code=" + campaign_code});
      }); 
    }       
  });   
  req.send();
}

window.addEvent('domready', function() {
    var partner_id = $('campaign_partner_id').getSelected().getProperty('value');
    var campaign_code = $('campaign_campaign_code').getProperty('value');
    update_creative_list_req.send({data: "partner_id=" + partner_id + "&campaign_code=" + campaign_code});
  });
