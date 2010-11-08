class AdInventorySourcesController < ApplicationController

  def new
    @ais = AdInventorySource.new
  end

  def create
    @ais = AdInventorySource.new(params[:ad_inventory_source])
    if @ais.save
      redirect_to campaigns_path
    else
      aises = AdInventorySource.find(:all)
      render :action => :new
    end
  end
end
