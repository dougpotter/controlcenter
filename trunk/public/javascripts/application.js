// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var ReportPage = {
  setDateRangeToLastSevenDays: function() {
    var range = ReportPage.createDateRangeToNow(7*86400);
    ReportPage.setDateRange(range[0], range[1]);
  },
  
  setDateRangeToLastThirtyDays: function() {
    var range = ReportPage.createDateRangeToNow(30*86400);
    ReportPage.setDateRange(range[0], range[1]);
  },
  
  setDateRangeToAllTime: function() {
    ReportPage.setDateRange(new Date(2010, 0, 1), new Date());
  },
  
  // length is in seconds
  createDateRangeToNow: function(length) {
    var end = new Date();
    // account for DST:
    // subtracting a particular number of days may move the date one
    // extra day back or forward if time is close to midnight and a
    // DST transition boundary is passed; fix hour at a number
    // sufficiently far away from midnight
    end.setHours(3);
    var start = new Date();
    start.setTime(end.getTime() - length*1000);
    return [start, end];
  },
  
  setDateRange: function(start, end) {
    $('start_year').value = start.getYear();
    $('start_month').value = start.getMonth()+1;
    $('start_day').value = start.getDate();
    
    $('end_year').value = end.getYear();
    $('end_month').value = end.getMonth()+1;
    $('end_day').value = end.getDate();
  },
  
  initGroupSummarizeBoxes: function() {
    var groupBoxes = $$('input.group-box');
    var summarizeBoxes = $$('input.summarize-box');
    var groupToSummarize = {};
    var summarizeToGroup = {};
    var groupClick = function(event) {
      var element = event.target;
      if (!element.checked) {
        var summarize = $(groupToSummarize[element.id]);
        summarize.checked = false;
      }
    };
    var summarizeClick = function(event) {
      var element = event.target;
      if (element.checked) {
        var group = $(summarizeToGroup[element.id]);
        group.checked = true;
      }
    };
    // a small hack assuming group and summarize boxes are ordered
    // in document order, and nothing else uses these class names
    for (var i = 0; i < groupBoxes.length; ++i) {
      var groupBox = groupBoxes[i];
      var summarizeBox = summarizeBoxes[i];
      groupToSummarize[groupBox.id] = summarizeBox.id;
      summarizeToGroup[summarizeBox.id] = groupBox.id;
    }
    var form = $('report_form');
    form.addEvent('click:relay(input[@class="group-box"])', groupClick);
    form.addEvent('click:relay(input[@class="summarize-box"])', summarizeClick);
  },
  
  showFilesWithStatus: function(status) {
    var rows = $$('#file_table tr');
    for (var i = 1; i < rows.length; ++i) {
      var row = rows[i];
      if (row.hasClass(status)) {
        row.style.display = '';
      } else {
        row.style.display = 'none';
      }
    }
  },
  
  showAllFiles: function() {
    var rows = $$('#file_table tr');
    for (var i = 1; i < rows.length; ++i) {
      rows[i].style.display = '';
    }
  }
};

var CampaignPage = {
  initialize: function() {
    var form = $('filter_form');
    var campaignList = $('campaign_list');
    var updateList = function(event) {
      new Form.Request(form, campaignList, {resetForm: false}).send();
      event.stop();
    };
    form.addEvent('change:relay(select)', updateList);
  }
};

function toggleHelp(helpKey) {
  var helpId = 'help-' + helpKey;
  var element = $(helpId);
  element.toggle();
}

function setNestedFormIndex(formText, index) {
  var regex_bracket = new RegExp("\\\[0\\\]", "g");
  var regex_underscore = new RegExp("_0_", "g");
  var regex_data_number = new RegExp("data-index=\"0\"", "g");
  var regex_parens = new RegExp("\\\(0\\\)", "g");
  var formNumber = (index).toString();
  var form_markup = 
  formText.replace(regex_bracket, "["+formNumber+"]").
  replace(regex_underscore, "_"+formNumber+"_").
  replace(regex_data_number, "data-index=\""+formNumber+"\"").
  replace(regex_parens, "("+formNumber+")");
  return form_markup;
}
