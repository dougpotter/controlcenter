window.addEvent('domready', function() {
  var ft = new FilteredTable('filtered_table', {
    menuBackgroundColor: '#9D9FA2',
    updateUrlTemplate: 'campaigns/filtered_edit_table?<filter_by>=<value>'
  });
});
