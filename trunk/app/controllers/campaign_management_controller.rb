class CampaignManagementController < ApplicationController
  def metrics 
    @partners = Partner.find(:all)
    @campaigns = Campaign.find(:all)
    @aises = AdInventorySource.find(:all)
    @creatives = Creative.find(:all)
    @audiences = Audience.find(:all)
    @mpms = MediaPurchaseMethod.find(:all)
  end
  def show
    render :layout => false
  end

  def update_form
    @var = "bye"
  end
end
