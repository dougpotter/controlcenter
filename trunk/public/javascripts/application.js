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
