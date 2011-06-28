var removeCreativeForm = function(creative_num) {
  var creative_entry_forms = $$('.creative_form_without_line_item');
  var number_of_creatives = $$('.creative_form_without_line_item').length;
  var creative_to_be_removed = $('creative_form_without_line_item[' + creative_num + ']');
  creative_to_be_removed.dispose();
}

