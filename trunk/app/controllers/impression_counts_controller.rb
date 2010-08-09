class ImpressionCountsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def create
    i = ImpressionCount.create!({:time_window_id => params[:time_window_id], :campaign_id => params[:campaign_id], :creative_id => params[:creative_id], :ad_inventory_source_id => params[:ad_inventory_source_id], :geography_id => params[:geography_id], :audience_id => params[:audience_id], :impression_count => params[:impression_count]})

    render :text => "success!!"
  end
end
