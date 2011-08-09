// Adds fields in a nested form. Relies on a few conventions in HTML:
// - all fields sets will be placed in a div of format
//    UNDERSCORED_PLURAL_MODEL_NAME_forms (e.g. action_tags_forms)
var appendNestedForm = function(options) {
  var newFormIndex = indexOfLast($$('.'+options.modelName+'_form'));
  var cleanFormMarkup = setNestedFormIndex(options.formMarkup, newFormIndex);
  var markup = Elements.from(cleanFormMarkup)[0];

  var contextStringUnderscore = options.contextString.replace(/(\]|\[)/g, "_");
  
  options.populate.each(function(tuple, index) {
    var value;
    var req = new Request({
      url: tuple[1],
      async: false,
      onSuccess: function(response) { value = response }
    }).send();

    markup.getElement(
      '#'+contextStringUnderscore + newFormIndex.toString() + '_' + tuple[0]
    ).set('value', value);
  });

  $(options.modelNamePlural+'_forms').grab(markup);

  $$('.'+options.modelName+'_minus_sign').each(function(minus_icon, index) {
    minus_icon.removeEvents();
    minus_icon.addEvent('click', function(e) { 
      e.stop();
      removeForm({ 
        index: minus_icon.get('data-index'),
        formType: options.modelName,
        contextString: options.contextString,
        contextStringUnderscore: contextStringUnderscore
      });
    });
  });
}

// Returns the integer value of the data-index attribute of the last element in 
// collection. If collection is empty, returns 0.
var indexOfLast = function(collection) {
  if (collection.length == 0) { return 1; }
  else { return parseInt(collection.getLast().get('data-index')) + 1; }
}


// Removes form fields from the DOM which are in the div named FORM_TYPES_forms and
// having data-index value of index. Replaces those fields with a hidden field that
// will, on form submission, reomve the element from the database.
var removeForm = function(options) {
  var hiddenRemoveField = new Element('input', {
    type: 'hidden',
    id: options.contextStringUnderscore + options.index+'__destroy',
    name: options.contextString +'['+ options.index+'][_destroy]',
    value: true 
  })
  var formToBeRemoved = $$("."+options.formType+"_form").filter(function(form) {
      if (form.get('data-index') == options.index) { return true; }
      else { return false; }
  })[0];
  hiddenRemoveField.replaces(formToBeRemoved);
}
