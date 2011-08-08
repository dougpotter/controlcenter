var appendActionTagForm = function(rawFormMarkup) {
  var newFormIndex = $$('.action_tag_form').length;
  var cleanFormMarkup = setNestedFormIndex(rawFormMarkup, newFormIndex);
  $('action_tags_forms').grab(Elements.from(cleanFormMarkup)[0]);

  $$('.action_tag_minus_sign').each(function(minus_icon, index) {
    minus_icon.removeEvents();
    minus_icon.addEvent('click', function(e) { 
      e.stop();
      alert("Should remove the form") });
  });
}

