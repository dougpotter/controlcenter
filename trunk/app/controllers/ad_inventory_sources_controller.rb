class AdInventorySourcesController < ApplicationController

  def new
    @ais = AdInventorySource.new
    @aises = AdInventorySource.all
  end

  def create
    @ais = AdInventorySource.new(params[:ais])
    if @ais.save
      redirect_to(new_ad_inventory_source_path, :notice => "AIS successfully saved")
    else
      render :action => :new
    end
  end

  def edit
    @ais = AdInventorySource.find(params[:id])
  end

  def update
    @ais = AdInventorySource.find(params[:id])
    if @ais.update_attributes(params[:ais])
      redirect_to(
        new_ad_inventory_source_path, 
        :notice => "#{@ais.name} successfully updated"
      )
    else
      render :action => :edit
    end
  end

  def destroy 
    @ais = AdInventorySource.destroy(params[:id])
  end
end
