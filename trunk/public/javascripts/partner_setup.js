var appendNestedForm = function(options) {
  var newFormIndex = indexOfLast($$('.'+options.modelName+'_form'));
  var cleanFormMarkup = setNestedFormIndex(options.formMarkup, newFormIndex);
  var markup = Elements.from(cleanFormMarkup)[0];
  var newSid;
  var req = new Request({
    url: options.sidUrl,
    async: false,
    onSuccess: function(response) { newSid = response }
  }).send();
  var contextStringUnderscore = options.contextString.replace(/(\]|\[)/g, "_");
  markup.getElement(
    '#'+contextStringUnderscore + newFormIndex.toString() + '_sid'
  ).set('value', newSid);
  $(options.modelNamePlural+'_forms').grab(markup);

  $$('.'+options.modelName+'_minus_sign').each(function(minus_icon, index) {
    minus_icon.removeEvents();
    minus_icon.addEvent('click', function(e) { 
      e.stop();
      removeForm({ index: minus_icon.get('data-index') });
    });
  });
}

// Returns the integer value of the data-index attribute of the last element in 
// collection. If collection is empty, returns 0.
var indexOfLast = function(collection) {
  if (collection.length == 0) { return 1; }
  else { return parseInt(collection.getLast().get('data-index')) + 1; }
}


// Removes from the DOM the action tag form with data-index value of index.
var removeForm = function(options) {
  var hiddenRemoveField = new Element('input', {
    type: 'hidden',
    id: 'partner_action_tags_attributes_'+options.index+'__destroy',
    name: 'partner[action_tags_attributes]['+options.index+'][_destroy]',
    value: true 
  })
  var tagToBeRemoved = $$(".action_tag_form").filter(function(form) {
      if (form.get('data-index') == options.index) { return true; }
      else { return false; }
  })[0];
  hiddenRemoveField.replaces(tagToBeRemoved);
}

window.addEvent('domready', function() {
  $$('.action_tag_minus_sign').each(function(minusIcon, index) {
    minusIcon.addEvent('click', function(e) {
      e.stop();
      removeForm(minusIcon.get('data-index'));
    });
  });
})

