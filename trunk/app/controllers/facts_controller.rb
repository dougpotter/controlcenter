require "yaml"

class FactsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  attr_accessor :attrs
  attr_accessor :fact_class

  def index
    @csv_rows = []
    @end_time = (Time.parse(params[:end_time]) rescue (Date.today - 1.day))
    @start_time = (Time.parse(params[:start_time]) rescue (@end_date - 7.day))

    render :text => nil, :status => 501 unless params[:frequency] = "hour" 

    code_ids = {
      :campaign_code => "campaign_id",
      :creative_code => "creative_id",
      :ais_code => "ad_inventory_source_id",
      :audience_code => "audience_id",
      :mpm_code => "media_purchase_method_id"
    }
    
    code_classes = {
      :campaign_code => Campaign,
      :creative_code => Creative,
      :ais_code => AdInventorySource,
      :audience_code => Audience,
      :mpm_code => MediaPurchaseMethod
    }

    group_by_dimensions = params[:dimensions].split(",")
    group_by_columns = []
    group_by_dimensions.each do |dim|
      if code_ids[dim.to_sym]
        group_by_columns << code_ids[dim.to_sym]
      else
        group_by_dimensions.delete(dim)
      end
    end
    group_by_columns.concat(["start_time", "end_time"])
    group_by_clause = group_by_columns.collect { |col|
      "#{ImpressionCount.connection.quote_column_name(col)}"
    }.join(", ")

    where_array = params.select { |k, v| 
      !([ :metrics, :dimensions, :start_time, :end_time, :frequency, :action, :controller, :format ].include?(k.to_sym)) 
    }
    where_clause = (where_array.collect { |dim|
      code_ids[dim[0].to_sym]
    }.compact.collect { |col|
      "#{ImpressionCount.connection.quote_column_name(col)} = ?"
    }.join(" AND "))
    
    where_values = where_array.collect { |row|
      code_classes[row[0].to_sym] ? code_classes[row[0].to_sym].send(:handle_to_id, row[1]) : nil
    }.compact

    grouped_sql_hash = {}
    params[:metrics].split(",").each_with_index do |fact_name, idx|
      fact_sum_term = "SUM(#{ImpressionCount.connection.quote_column_name(fact_name)})"
      table_name = ImpressionCount.connection.quote_table_name(fact_name.pluralize)
      grouped_sql_result = ImpressionCount.find_by_sql([
        "SELECT #{group_by_clause}, #{fact_sum_term} " +
        "FROM #{table_name} WHERE start_time >= ? AND " +
        "end_time <= ? #{where_clause.empty? ? "" : "AND"} " +
        "#{where_clause} GROUP BY #{group_by_clause}"
      ].concat([@start_time, @end_time]).concat(where_values))

      grouped_sql_result.each do |row|
        grouped_attr_array = []
        group_by_dimensions.each do |group_dim|
          grouped_attr_array <<
            row.send(code_ids[group_dim.to_sym].gsub("_id", "")).send(group_dim)
        end
        grouped_attr_array.concat([row.start_time, row.end_time])
        grouped_sql_hash[grouped_attr_array] ||= []
        grouped_sql_hash[grouped_attr_array][idx] = row.attributes[fact_sum_term]
      end
    end
    
    facts = params[:metrics].split(",")
    
    @csv_rows = []
    @csv_rows[0] = []
    @csv_rows[0].concat(group_by_dimensions)
    @csv_rows[0].concat(["start_time", "end_time"])
    @csv_rows[0].concat(facts)
    
    grouped_sql_hash.each do |k, v|
      @csv_rows << k.concat(v)
    end
    
    respond_to do |format|
      format.csv do 
        render_csv("#{facts.join("-")}" +
                   "#{@start_time.strftime("%Y%m%d")}-#{@end_time.strftime("%Y%m%d")}")
      end
    end
  end

  def create
    discern_facts_present
    for fact in @facts_present
      @attrs = {}
      @fact_class = ActiveRecord.const_get(fact.to_s.classify)
      fill_attrs
      @fact_class.create!(@attrs)
    end

    render :text => nil, :status => 200
  end

  def update
    discern_facts_present
    for fact in @facts_present
      @attrs = {}
      @fact_class = ActiveRecord.const_get(fact.to_s.classify)
      fill_attrs
      lookup_attrs = {} 
      @attrs.select { |k, v| v != nil && v != "" && k.to_s != fact.to_s }.each do |el|
        lookup_attrs[el[0]] = el[1]
      end
      facts = @fact_class.find(:all, :conditions => lookup_attrs)
      facts[0].send("#{fact}=", facts[0].send(fact) + @attrs[fact].to_f) if facts.size == 1 && params[:operation] == "increment"
      facts[0].save!
    end

    render :text => nil, :status => 200
  end

  def new
    @fact_class = ActiveRecord.const_get(params[:table_name].classify)
    required_dimensions = @fact_class.new.business_attributes
    render :text => { "required_dimensions" => required_dimensions }.to_yaml
  end

  private
  def discern_facts_present
    @facts_present = []
    all_facts = [:impression_count, :click_count]
    for fact in all_facts
      @facts_present << fact if params.member?(fact)
    end
  end

  def fill_attrs
    parse_time 
    parse_geography
    fill_fks
    fill_fact_value
  end

  def parse_time
    @attrs[:start_time] = params.delete(:start_time)
    @attrs[:end_time] = params.delete(:end_time)
    @attrs[:duration_in_minutes] = params.delete(:duration_in_minutes)
  end

  def parse_geography
    @attrs[:geography_id] = params.delete(:geography)
  end

  def fill_fks
    fact_fks = @fact_class.new.attributes.keys
    fact_fks.each do |fk|
      if fk.match(/.*_id/)
        fk_class = ActiveRecord.const_get(fk.to_s[0..-4].classify)
        handle = fk_class.new.get_handle
        fk_value = fk_class.handle_to_id(params[handle])
        @attrs[fk.to_sym] = fk_value
      end
    end
  end

  def fill_fact_value
    fact_as_sym = @fact_class.to_s.underscore.to_sym
    @attrs[fact_as_sym] = params[fact_as_sym]
  end
end
