class ClickCountsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def create
    c = ClickCount.create!({:campaign_id => params[:campaign_id], :creative_id => params[:creative_id], :ad_inventory_source_id => params[:ad_inventory_source_id], :geography_id => params[:geography_id], :audience_id => params[:audience_id], :time_window_id => params[:time_window_id], :click_count => params[:click_count]})
    render :text => "hi there #{c.inspect}"
  end
end
