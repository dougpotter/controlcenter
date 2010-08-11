require "rubygems"
require "faster_csv"

class BeaconReportGraphsController < ApplicationController

  def show    
    @end_date = (Date.parse(params[:end_date]) rescue (Date.today - 1.day))
    @start_date = (Date.parse(params[:start_date]) rescue (@end_date - 7.days))
    
    @partner = Partner.find_by_pid(params[:id])
    
    # TODO: Rewrite this where_hash / where_array business in some more
    # reusable form.
    where_array = where_hash_from_params(
      params, 
      PartnerBeaconRequest.column_names - ["id"]
    ).merge({ "pid" => params[:id] }).to_a
    where_clause = where_array.collect { |row|
      # TODO: Move this to a function elsewhere
      "#{PartnerBeaconRequest.connection.quote_column_name(row[0])} = ?"
    }.join(" AND ")
    where_values = where_array.collect { |row| row[1] }
    
    # TODO: Abstract find_by_sql custom SQL statement to something re-usable
    # for all time-series models
    grouped_sql_result = PartnerBeaconRequest.find_by_sql([
      "SELECT DATE(request_time), HOUR(request_time), COUNT(*), " + 
      "COUNT(DISTINCT xguid) FROM partner_beacon_requests " + 
      "WHERE DATE(request_time) >= ? AND DATE(request_time) <= ? AND " +
      "#{where_clause} " +
      "GROUP BY DATE(request_time), HOUR(request_time)"
    ].concat([@start_date, @end_date]).concat(where_values))
    
    grouped_sql_hash = {}
    grouped_sql_result.each do |res|
      d = Date.parse(res["DATE(request_time)"])
      h = res["HOUR(request_time)"].to_i
      grouped_sql_hash[d] ||= {}
      grouped_sql_hash[d][h] ||= {}
      grouped_sql_hash[d][h]["unique"] = res["COUNT(DISTINCT xguid)"].to_i
      grouped_sql_hash[d][h]["total"] = res["COUNT(*)"].to_i
    end

    data_total = []
    data_unique = []
    @csv_rows = []
    y_max = 0
    (@start_date..@end_date).each do |date|
      (0..23).each do |hour|
        x = (date.to_time(:utc) + hour.hours).to_i
        y_total = ((grouped_sql_hash[date][hour]["total"] || 0) rescue 0)
        y_unique = ((grouped_sql_hash[date][hour]["unique"] || 0) rescue 0)
        
        respond_to do |format|
          format.html do
            y_max = y_total if y_total > y_max
            data_total << ScatterValue.new(x, y_total)
            data_unique << ScatterValue.new(x, y_unique)
          end
          
          format.csv do
            @csv_rows << [Time.at(x).to_s(:db), y_total, y_unique]
          end
        end
      end
    end
    
    respond_to do |format|
      format.html do
        dot = HollowDot.new
        dot.size = 3
        dot.halo_size = 2
        dot.tooltip = "#date: m/d/y H#:00<br>Value: #val#"

        line = ScatterLine.new("#DB1750", 3)
        line.values = data_total
        line.default_dot_style = dot

        line2 = ScatterLine.new("#5F9EA0", 3)
        line2.values = data_unique
        line2.default_dot_style = dot

        x = XAxis.new
        x.set_range(@start_date.to_time(:utc).to_i, 
          (@end_date.to_time(:utc) + 23.hours).to_i)
        x.steps = 86400

        labels = XAxisLabels.new
        labels.text = "#date: m/d/y H#:00"
        labels.steps = 86400
        labels.visible_steps = 1
        labels.rotate = 90

        x.labels = labels

        y = YAxis.new
        y.set_range(0,(y_max+100).round,100)

        chart = OpenFlashChart.new
        title = Title.new("Beacon Activity, #{@partner.name}")

        chart.title = title
        chart.add_element(line)
        chart.add_element(line2)
        chart.x_axis = x
        chart.y_axis = y

        render :text => chart, :layout => false
      end
      
      format.csv do
        render_csv("#{@partner.pid}-" +
          "#{@start_date.strftime("%Y%m%d")}-#{@end_date.strftime("%Y%m%d")}")
      end
    end
    
  end
  
  private
  def safe_where_clause_from_hash(where_hash)
  end
  
  # Returns hash of `column_name` => `column_value` 's from params and valid
  # parameter_names
  def where_hash_from_params(params, parameter_names)
    where_hash = {}
    parameter_names.each do |parameter_name|
      en = params["#{parameter_name}_equals".to_sym]
      ln = params["#{parameter_name}_like".to_sym]
      rn = params["#{parameter_name}_rlike".to_sym]

      [en, ln, rn].each do |val|
        where_hash[parameter_name] = val unless val.blank?
      end
    end
    
    return where_hash
  end
end
