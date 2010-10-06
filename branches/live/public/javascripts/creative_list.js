window.addEvent('domready', function(){

    var req = new Request.HTML({
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

    $('campaign_partner_id').addEvent('change', function(){
      var partner_id = $('campaign_partner_id').getSelected().getProperty('value');
      req.send({data: "partner_id=" + partner_id});
      });

});
