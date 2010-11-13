var update_creative_list_req = new Request.HTML({
  url: '../creatives',
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
  var req = new Request.HTML({
    url: '../creatives/form_without_campaign',
    method: 'get',
    onSuccess: function(txt) {
      // inject new creative form
      $('new_creative_form').set('text', "");
      $('new_creative_form').adopt(txt);
      $('creative_submit').addEvent('click', function(event) {        
        event.stop();        
        $('new_creative').send();
        var partner_id = $('campaign_partner_id').getSelected().getProperty('value');
        update_creative_list_req.send({data: "partner_id=" + partner_id});
      }); 
    }       
  });   
  req.send();
}
