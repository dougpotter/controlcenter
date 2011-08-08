var appendActionTagForm = function(rawFormMarkup, sid_url) {
  var newFormIndex = indexOfLast($$('.action_tag_form'));
  var cleanFormMarkup = setNestedFormIndex(rawFormMarkup, newFormIndex);
  var markup = Elements.from(cleanFormMarkup)[0];
  var newSid;
  var req = new Request({
    url: sid_url,
    async: false,
    onSuccess: function(response) { newSid = response }
  }).send();
  markup.getElement(
    '#partner_action_tags_attributes_' + newFormIndex.toString() + '_sid'
  ).set('value', newSid);
  $('action_tags_forms').grab(markup);

  $$('.action_tag_minus_sign').each(function(minus_icon, index) {
    minus_icon.removeEvents();
    minus_icon.addEvent('click', function(e) { 
      e.stop();
      removeForm(minus_icon.get('data-index'));
    });
  });
}

// Returns the integer value of the data-index attribute of the last element in 
// collection. If collection is empty, returns 0.
var indexOfLast = function(collection) {
  if (collection.length == 0) { return 0; }
  else { return parseInt(collection.getLast().get('data-index')) + 1; }
}


// Removes from the DOM the action tag form with data-index value of index.
var removeForm = function(index) {
  $$(".action_tag_form").filter(function(form) {
    if (form.get('data-index') == index) { return true; }
    else { return false; }
  }).dispose();
}

