class CampaignManagementController < ApplicationController
  def metrics 
    @partners = Partner.find(:all)
    @campaigns = Campaign.find(:all)
    @aises = AdInventorySource.find(:all)
    @creatives = Creative.find(:all)
    @audiences = Audience.find(:all)
    @mpms = MediaPurchaseMethod.find(:all)
  end
  
  def index
    @campaigns = Campaign.all(:order => 'campaign_code')
  end
  
  def show
    render :layout => false
  end

  def update_form
    @var = "bye"
  end
  
  def new
    @campaign = Campaign.new
    prepare_form
  end
  
  def create
    @campaign = Campaign.new(params[:campaign])
    if @campaign.save
      redirect_to campaigns_path
    else
      prepare_form
      render :action => 'new'
    end
  end
  
  def edit
    @campaign = Campaign.find(params[:id], :include => :ad_inventory_sources)
    prepare_form
  end
  
  def update
    @campaign = Campaign.find(params[:id])
    @campaign.attributes = params[:campaign]
    if @campaign.save
      redirect_to campaigns_path
    else
      prepare_form
      render :action => 'edit'
    end
  end
  
  private
  
  def prepare_form
    @partners = Partner.find(:all, :order => 'name')
    @ad_inventory_sources = AdInventorySource.all(:order => 'name')
  end
end
