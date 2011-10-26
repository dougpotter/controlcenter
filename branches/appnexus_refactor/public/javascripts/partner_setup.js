// Adds fields in a nested form. Options should be an object consisting of these 
// key value pairs:
//
// modelName: the name of the model in quesiton, string, underscored, singular
// modelNamePlural: the name of the model in question, string, underscored, plural
// contextString: the Rails-convention string which forms the context portion
//                of the id attributes on these inputs.
//                e.g. partner[action_tags_attributes] would be the contextString
//                for an input with name partner[action_tags_attributes][0][url]
// formMarkup: a JS-escaped string consisting of a div enclosing a removal input 
//             and the form markup. all should have index value 0.
// populate: an array of tuple arrays comprised of name-url combinations. the name
//           is the name of the field which should be pre-populated, and the url
//           is the url at which a legal text value for pre-population will be 
//           returned.
//           e.g. [ [ "sid", "http://control.xgraph.net/action_tags/sid" ] ]
//
// Relies on a few conventions in HTML. For these
// examples, I will pretend the model in question is the ActionTag. Pluralization,
// underscoring, etc when naming form elements and divs should all be done in like
// fashion for models of other names. Also, I will use a # to mean 'a number', not
// the literal pund sign:
// - somewhere on the page should be an image input with id="add_action_tag"
// - all fields sets will be placed in a div with id="action_tags_forms"
// - the field sets themselves should be wrapped in a div with
//   class="action_tag_form" and data-index=#
// - inside that div wrapper (of field sets) should also be an image input with
//   id="action_tag_minus_sign_#" where # matches the data-index value of the 
//   enclosing div
var appendNestedForm = function(options) {
  var newFormIndex = indexOfLast($$('.'+options.modelName+'_form'));
  var numberedFormMarkup = setNestedFormIndex(options.formMarkup, newFormIndex);
  var domForm = Elements.from(numberedFormMarkup)[0];

  var contextStringUnderscore = options.contextString.replace(/(\]|\[)/g, "_");
  
  options.populate.each(function(tuple, index) {
    var value;
    var req = new Request({
      url: tuple[1],
      async: false,
      onSuccess: function(response) { value = response }
    }).send();

    domForm.getElement(
      '#'+contextStringUnderscore + newFormIndex.toString() + '_' + tuple[0]
    ).set('value', value);
  });

  $(options.modelNamePlural+'_forms').grab(domForm);

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
  if (formToBeRemoved.get('data-new_record') == 'true') { formToBeRemoved.destroy() }
  else { hiddenRemoveField.replaces(formToBeRemoved); }
}
