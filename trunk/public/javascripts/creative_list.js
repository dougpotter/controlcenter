var removeCreativeForm = function(creative_num) {
  var creative_entry_forms = $$('.creative_form_without_line_item');
  var creative_to_be_removed = $('creative_form_without_line_item[' + creative_num + ']');
  if ($('creative_form_without_line_item['+creative_num+']').getElement('input#campaign_creatives_attributes_'+creative_num+'_existing_record') != null) {
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
