window.addEvent('domready', function(){

    var req = new Request.HTML({
url: 'index_by_advertiser',
mtheod: 'get',
onSuccess: function(txt) {
$('summary_table').set('text','');
$('summary_table').adopt(txt);
}
});

    $('partner_id').addEvent('change', function() {
      var partner_id = $('partner_id').getSelected().getProperty('value');
      req.send({data: "partner_id=" + partner_id});
      });
    });
