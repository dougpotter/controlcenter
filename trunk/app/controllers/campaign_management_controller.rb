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
    @partners = Partner.all(:order => :name)
    @ad_inventory_sources = AdInventorySource.all(:order => :ais_code)
  end
  
  def filter_list
    scope = Campaign
    %w(partner_id ad_inventory_source_id).each do |column|
      if value = params[column]
        scope = scope.scoped(:conditions => ["#{Campaign.quote_identifier(column)}=?", value])
      end
    end
    @campaigns = scope.all(:order => 'campaign_code')
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
    @campaign = Campaign.new
    update_campaign_objects
    if save_campaign
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
    update_campaign_objects
    if save_campaign
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
    @creatives = Creative.all(:order => 'name')
    @creative_sizes = CreativeSize.all(:order => 'common_name')
  end
  
  def update_campaign_objects
    @campaign.attributes = params[:campaign]
    if @campaign.partner.nil?
      @new_partner = Partner.new(params[:new_partner])
      @campaign.partner = @new_partner
    end
    if !params[:use_creatives].blank?
      @creatives = Creative.find(params[:use_creatives].keys)
    else
      @creatives = []
    end
  end
  
  def save_campaign
    # if partner is invalid, check campaign validity anyway so that
    # error messages for campaign are displayed
    @campaign.valid?
    ok_to_save = (@new_partner.nil? || @new_partner.valid?) && @campaign.valid?
    if ok_to_save
      new_record = @campaign.new_record?
      Campaign.transaction do
        if @new_partner
          @new_partner.save!
        end
        @campaign.save!
        
        # new campaigns cannot have any creatives
        unless new_record
          @campaign.creatives.each do |creative|
            unless @creatives.include?(creative)
              @campaign.creatives.delete(creative)
            end
          end
        end
        @creatives.each do |creative|
          # new campaigns cannot have any creatives
          if new_record || !@campaign.creatives.include?(creative)
            @campaign.creatives << creative
          end
        end
      end
    end
    ok_to_save
  end
end
