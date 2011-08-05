var appendActionTagForm = function(rawFormMarkup) {
  var newFormIndex = $$('.action_tag_form').length;
  var cleanFormMarkup = setNestedFormIndex(rawFormMarkup, newFormIndex);
  $('action_tags_forms').grab(Elements.from(cleanFormMarkup)[0]);
}

