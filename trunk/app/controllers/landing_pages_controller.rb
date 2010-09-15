class LandingPagesController < ApplicationController
  REPORT_TZ = ActiveSupport::TimeZone['America/New_York']
  
  def metrics 
    @partners = Partner.all(:order => :name)
    @campaigns = Campaign.all(:order => :campaign_code)
    @creatives = Creative.all(:order => :creative_code)
  end
  
  # A note about time zones:
  # Our backend processes operate in UTC.
  # Reporting operates in local time for convenience.
  # For consistency between reports generated by New York and California
  # office, the "local time" is not the time zone of the user, but instead
  # is defined to be New York time.
  # This method expects incoming dates to be in New York time and converts
  # them to UTC for actual report generation.
  #
  # Further, calculations on times with time zones are not always done
  # the way programmer may intend, for example:
  #
  # >> tz = ActiveSupport::TimeZone['America/New_York']           
  # >> tz.local(2010, 2, 1)
  # => Mon, 01 Feb 2010 00:00:00 EST -05:00
  # >> tz.local(2010, 2, 1) + 5.months
  # => Thu, 01 Jul 2010 00:00:00 EDT -04:00
  # >> tz.at(tz.local(2010, 2, 1).to_f + 5.months)
  # => Thu, 01 Jul 2010 01:00:00 EDT -04:00
  #
  # For best results arithmetic should be done on integer values with
  # explicit conversion from/to time objects.
  def report
    start_date = REPORT_TZ.local(params[:start_year], params[:start_month], params[:start_day])
    end_date = REPORT_TZ.local(params[:end_year], params[:end_month], params[:end_day])
    frequency = params[:frequency]
    metric = params[:metric]
    group = {}
    %w(campaign creative partner).each do |key|
      if params["#{key}_group"] && params["#{key}_group"].to_i > 0
        group[key] = true
      end
    end
    format = params[:format]
    format = 'csv' unless %w(csv html).include?(format)
    
    time_format = FactsController::TIME_FORMAT
    start_time = start_date.utc.strftime(time_format)
    end_time = end_date.utc.strftime(time_format)
    metrics = metric
    dimensions = group.keys.join(',')
    tz_offset = 0
    
    redirect_to facts_path(
      :start_time => start_time, :end_time => end_time,
      :frequency => frequency,
      :metrics => metrics,
      :dimensions => dimensions,
      :tz_offset => tz_offset,
      :format => format
    )
  end

  def update_form
    @partner = params[:partner_select].to_i
    @campaigns = Campaign.find(:all, :conditions => {:partner_id => @partner})
    @partners = Partner.find(:all)
    render :partial => 'form'
  end
end
