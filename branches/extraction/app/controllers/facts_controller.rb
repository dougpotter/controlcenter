class FactsController < ApplicationController
  TIME_FORMAT = "%Y-%m-%d %H:%M:%S".freeze

  # skip auth before :create should be deleted for production
  skip_before_filter :verify_authenticity_token, :only => [:create, :update, :index]

  # Takes url conforming to spec and returns fact aggregation report
  def index

    # parse params hash 
    @fact_aggregation = FactAggregation.new
    options = {
      :where => params[:filters],
      :group_by => params[:dimensions].split(","),
      :frequency => params[:frequency],
      :summarize => params[:summarize] ? params[:summarize].split(",") : [],
      :tz_offset => params[:tz_offset]
    }
    # aggregate facts
    begin
      params[:metrics].split(",").each do |metric|
        ActiveRecord.const_get(metric.classify).aggregate(@fact_aggregation, options)
      end
    rescue Interrupt, SystemExit
      raise
    rescue
      render :text => nil, :status => 422
      return 
    end

    respond_to do |format|
      format.html
      format.csv do 
        @csv_rows = @fact_aggregation.to_csv({
          :facts => params[:metrics].split(","),
          :dimensions => params[:dimensions].split(","),
          :frequency => params[:frequency]
        })
        render_csv :data => @csv_rows
      end
    end
  end

  def create
    create_many
  end

  def create_many
    fact_classes_from_params.each do |fact_class|
      fact = fact_class.new(params)
      unless fact.save!
        render :text => nil, :status => 422
        return
      end
    end

    render :text => nil, :status => 200
    return
  end

  def update
    update_many
  end

  def update_many
    fact_classes_from_params.each do |fact_class|
      all_facts = fact_class.find_all_by_dimensions(:conditions => params)
      if all_facts.size == 1
        if params[:operation] == "increment"
          params.merge!({
            fact_class.scalar_fact => (
              all_facts[0].send(fact_class.scalar_fact) + 
              params[fact_class.scalar_fact].to_f
          )
          })
        end

        unless all_facts[0].update_attributes(params)
          render :text => nil, :status => 422
          return
        end
      else
        render :text => nil, :status => 404  # TODO: Update spec doc
        return
      end
    end

    render :text => nil, :status => 200
  end

  private
  def fact_classes_from_params
    fact_classes = []
    for param in params.keys
      if Fact.is_fact?(param)
        fact_classes << ActiveRecord.const_get(param.classify)
      end
    end
    fact_classes
  end
end
