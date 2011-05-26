var FilteredTable = new Class({
Implements: [Options],

options: {},

initialize: function(tableDivId, options) {
  options.tableDiv = $(tableDivId);
  this.setOptions(options);
  window.filterMenus = this.filterMenus();
  window.prepareTable = this.prepareTable.bind(this);
  this.prepareTable();
},

prepareTable: function() {
  this.setTransparency();
  this.setMenus();
  this.setLinkEvents();
  this.setShowMenuEvents();
},

setTransparency: function() {
  var transparency = new Element('div', {
    id: 'table_transparency',
    styles: {
      'z-index': '-1',
      'opacity': '0',
      'background': $('content').getStyle('background-color'),
      'position': 'absolute'
    }
  });
  this.options.tableDiv.grab(transparency, 'top');
  this.transparency = transparency; 
},

setMenus: function() {
  var headersWithFilters = $$('.filtered');
  headersWithFilters.each(function(header, index) {
    copyOfMenu= window.filterMenus[index].clone(true,true).
      cloneEvents(window.filterMenus[index]);
    for (i = 0; i < copyOfMenu.children[1].children.length; i++) {
      copyOfMenu.children[1].children[i].children[0].
        cloneEvents(window.filterMenus[index].children[1].children[i].children[0]);
    };
    copyOfMenu.setStyle('opacity', '0'); // bug in clone?
    header.grab(copyOfMenu);
  }.bind(this));
},

setLinkEvents: function() {
  self = this;
  $$('.filtered').each(function(header) {
    header.getElements('.update_link').each(function(link) {
      link.addEvent('click', function(e) {
        e.stop();
        var updateUrl = this.get('data-update_url');
        var request = new Request.HTML({
          url: updateUrl,
          update: self.options.tableDiv,
          onSuccess: function() {
            window.prepareTable();
          }
        }).send();
      });
    });
  });
},

setShowMenuEvents: function() {
  var headersWithFilters = $$('.filtered');
  var filterMenus = $$('.filter_menu');
  var numFilters = headersWithFilters.length;

  headersWithFilters.each(function(header) {
    header.addEvent('click', function(e) {
      e.stop();
      transparency = $('table_transparency');
      transparency.setStyle('height', $('filtered_table').getHeight());
      transparency.setStyle('width', $('filtered_table').getWidth());

      var menu = $(header.id+'_filter_menu');

      if (menu.get('opacity') == 0) {
        this.showMenu(menu);
        document.addEvent('click', function(e) { 
          this.removeMenu(menu);
        }.bind(this));
        menu.addEvent('click', function(e) { e.stopPropagation(); });
      } else {
        this.removeMenu(menu);
      }
    }.bind(this));
  }.bind(this));
},

removeMenu: function(menu) {
  new Fx.Tween( menu, { property: 'opacity', duration: 'short' }).start(0.0);
  new Fx.Tween($('table_transparency'), 
      { property: 'opacity', duration: 'short' }).start(0);
  transparency.setStyle('z-index', '0');
},

showMenu: function(menu) {
  new Fx.Tween(menu, { property: 'opacity', duration: 'short' }).start(1.0);
  new Fx.Tween($('table_transparency'), 
      { property: 'opacity', duration: 'short' }).start(0.4);
  transparency.setStyle('z-index', '1');
},

filterMenus: function() {
  var headersWithFilters = $$('.filtered');
  var filterMenus = [];

  headersWithFilters.each(function(header, index) {
    var filterMenu = this.filterMenuFor(header, this.menuBackgroundColor);
    var listOfLinks = this.listOfLinksFor(header);
    filterMenu.grab(listOfLinks);
    filterMenus[index] = filterMenu;
  }.bind(this));
  return filterMenus;
},

listOfLinksFor: function(header, requestEventFunction) {
  var serverObjectName = header.get('data-model_name');
  var listOfLinks = new Element('ul', { id: serverObjectName });
  var headerIndex;
  $$('th').each(function(thisHeader, index) {
    if (thisHeader.get('id') == header.id) { headerIndex = index; }
  });
  var columnSelector = 'td:nth-child('+(headerIndex + 1)+')';

  var seenLinks = new Hash();

  $$(columnSelector).each(function(tableData) {
    var serverObjectValue = tableData.get('data-model_value');
    if (seenLinks.get(serverObjectValue) == null) {
      seenLinks.set(serverObjectValue, true);
      var updateUrl = this.options.updateUrlTemplate.
        replace(/<(.*?)>/, serverObjectName).
        replace(/<(.*?)>/, serverObjectValue);
      var link = new Element('a', { 
        id: serverObjectValue,
        href: '#',
        text: tableData.get('text'),
        'class': 'update_link',
        'data-model_name': serverObjectName,
        'data-model_value': serverObjectValue,
        'data-update_url': updateUrl 
      });
      var listItem = new Element('li').grab(link)
      listOfLinks.grab(listItem);
    }
  }.bind(this));

  return listOfLinks;
},

filterMenuFor: function(header, menuBackgroundColor) {
  var filterMenu = new Element('div', {
    id: header.get('id') + '_filter_menu',
    'class': 'filter_menu',
    styles: {
      visibility: 'hidden',
      opacity: '0',
      zoom: '1',
      opacity: '0',
      border: 'double',
      'z-index': '2', 
      position: 'absolute',
      background: menuBackgroundColor,
      'font-size': '12px',
      'padding-left': '5px',
      'padding-right': '5px',
      'padding-top': '1px',
      'margin-left': '15px',
      'margin-top': '3px'
    }
  });

  // build menu title
  var headerText = header.getProperty('text');
  var menuHeader = new Element('h2', {
    text: 'Filter by ' + headerText,
    styles: {
      'font-size': '14px',
      'font-weight': 'bold',
      'margin-bottom': '3px'
    }
  });
  filterMenu.grab(menuHeader, 'top');
  return filterMenu;
}
});
