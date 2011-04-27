class AdInventorySourcesController < ApplicationController

  def new
    @ais = AdInventorySource.new
    @aises = AdInventorySource.all
  end

  def create
    @ais = AdInventorySource.new(params[:ais])
    if @ais.save
      redirect_to :action => :new
    else
      render :action => :new
    end
  end

  def edit
    @ais = AdInventorySource.find(params[:id])
  end

  def update
    @ais = AdInventorySource.find(params[:id])
    if @ais.update_attributes(params[:audience])
      redirect_to :action => :new
    else
      render :action => :edit
    end
  end
end
