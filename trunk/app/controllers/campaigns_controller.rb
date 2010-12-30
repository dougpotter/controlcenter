class CampaignsController < ApplicationController
  def new
    @campaign = Campaign.new
    @line_items = LineItem.all
    @campaign_types = [ "Ad-Hoc", "Retargeting" ]
    @aises = AdInventorySource.all
  end
end
