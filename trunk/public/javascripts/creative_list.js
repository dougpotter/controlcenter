var removeCreativeForm = function(creative_num) {
  var creative_entry_forms = $$('.creative_form_without_line_item');
  var creative_to_be_removed = $('creative_form_without_line_item[' + creative_num + ']');
  if ($('creative_form_without_line_item['+creative_num+']').get('data-existing-record') == "true") {
    var el = new Element("input", { 
      type: "hidden", 
      id: "campaign_creatives_attributes_"+creative_num+"__disassociate",
      name: "campaign[creatives_attributes]["+creative_num+"][_disassociate]",
      value: "true" })
    el.replaces(creative_to_be_removed);
  }
  else {
    creative_to_be_removed.dispose();
  }
}


function setCreativeCode(formNumber, creativeCodeUrl) {
  var creativeCode = newValidCreativeCode(creativeCodeUrl);
  $("creative_form_without_line_item["+formNumber+"]").
    getElement("#campaign_creatives_attributes_"+formNumber+"_creative_code").
    set('value', creativeCode);
}

function newValidCreativeCode(creativeCodeUrl) {
  var creativeCode;
  var request = new Request({
    url: creativeCodeUrl,
    async: false,
    onSuccess: function(response) {
      creativeCode = response;
    }
  });
  request.send();
  return creativeCode;
}
