window.addEvent('domready', function() {
  $$('.status_indicator.error').each(function(statusBox) {
    $(statusBox).addEvent('click', function(e) {
      toggleVisibility($(this).getNext());
    });
  });
});


function toggleVisibility(notices) {
  if ($(notices).getStyle('visibility') == 'visible') {
    $(notices).setStyle('visibility', 'hidden');
  } else {
    $(notices).setStyle('visibility', 'visible');
  }
}
