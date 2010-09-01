class FactsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:update, :index]

  def index
    # Returns object of type FactAggregation
    # Example URL:
    # http://127.0.0.1:3000/metrics.csv?metrics=click_count&dimensions=campaign,start_time&frequency=hour&start_time=%222010-08-25%2000:00:00%22&end_time=%222010-08-30%2000:00:00%22
    @fact_aggregation = Fact.aggregate({
      :include => params[:metrics].split(","),
      :group_by => params[:dimensions].split(","),
      :where => where_conditions_from_params,
      :frequency => params[:frequency]
    })

    respond_to do |format|
      format.html
      format.csv do @csv_rows = @fact_aggregation.to_csv
        render_csv("facts")  # TODO: Codify name (#616)
      end
    end
  end

  def create
    create_many
  end

  def create_many
    fact_classes_from_params.each do |fact_class|
      fact_class.new(params)
      if fact_class.save!
        render :text => nil, :status => 200
      else
        render :text => nil, :status => 422
      end
    end
  end

  def update
    update_many
  end

  def update_many
    fact_classes_from_params.each do |fact_class|
      all_facts = fact_class.find_all_by_dimensions(:conditions => params)
      if all_facts.size == 1
        all_facts[0].update(params)
        if all_facts[0].save!
          render :text => nil, :status => 200
        else
          render :text => nil, :status => 422
        end
      else
        render :text => nil, :status => 404  # TODO: Update spec doc
      end
    end
  end

  private
  def fact_classes_from_params
    fact_classes = []
    for fact in params[:metrics]
      fact_classes << ActiveRecord.const_get(fact.classify)
    end
  end

  def where_conditions_from_params
    s = []
    s << "start_time >= \"#{Time.parse(params[:start_time]).strftime("%Y-%m-%d %H:%M:%S")}\""
    s << "end_time <= \"#{Time.parse(params[:end_time]).strftime("%Y-%m-%d %H:%M:%S")}\""
    s.join(" AND ")
  end
end
