class FactFilingController < ApplicationController
  skip_before_filter :verify_authenticity_token

  attr_accessor :attrs
  attr_accessor :fact_class

  def show
    @csv_rows = []
    @end_time = (Time.parse(params[:end_time]) rescue (Date.today - 1.day))
    @start_time = (Time.parse(params[:start_time]) rescue (@end_date - 7.day))
    @fact_class = ActiveRecord.const_get(params[:table_name].classify)
    results = @fact_class.find(:all, :conditions => ["start_time >= ? AND end_time <= ?", @start_time, @end_time])

    @csv_rows << results.first.attributes.keys.join(",")
    results.each do |row|
      @csv_rows << row.attributes.values.join(",")
    end

    respond_to do |format|
      format.csv do 
        render_csv("#{params[:table_name]}-" +
                   "#{@start_time.strftime("%Y%m%d")}-#{@end_time.strftime("%Y%m%d")}")
      end
    end
  end

  def create
    @attrs = {}
    @fact_class = ActiveRecord.const_get(params[:table_name].classify)
    fill_attrs
    fact = @fact_class.create!(attrs)
    render :text => "success!!!"
  end

  def new
    require 'yaml'
    @fact_class = ActiveRecord.const_get(params[:table_name].classify)
    required_dimensions = @fact_class.new.business_attributes
    render :text => {"required_dimensions:" => required_dimensions}.to_yaml
  end

  private
  def fill_attrs
    handle_time
    handle_geography
    fill_fks
    fill_fact_value
  end

  def handle_time
    @attrs[:start_time] = params.delete(:start_time)
    @attrs[:end_time] = params.delete(:end_time)
    @attrs[:duration_in_minutes] = params.delete(:duration_in_minutes)
    puts "after time: " + @attrs.inspect
  end

  def handle_geography
    @attrs[:geography_id] = params.delete(:geography)
  end

  def fill_fks
    fact_fks = @fact_class.new.attributes.keys
    fact_fks.each do |fk|
      if fk.match(/.*_id/)
        fk_class = ActiveRecord.const_get(fk.to_s[0..-4].classify)
        business_code = fk_class.new.business_code
        fk_value = fk_class.code_to_pk(params[business_code])
        @attrs[fk.to_sym] = fk_value
      end
    end
  end

  def fill_fact_value
    fact_as_sym = @fact_class.to_s.underscore.to_sym
    @attrs[fact_as_sym] = params[fact_as_sym]
  end
end
