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
    filter_list
  end
  
  def filter_list
    scope = Campaign
    
    if !(value = params[:ad_inventory_source_id]).blank?
      @ad_inventory_source_id = value.to_i
      scope = scope.scoped(:include => :ad_inventory_sources, :conditions => ['ad_inventory_sources.id=?', @ad_inventory_source_id])
    end
    
    if !(value = params[:partner_id]).blank?
      @partner_id = value.to_i
      scope = scope.scoped(:conditions => ["partner_id=?", @partner_id])
    end
    
    %w(start_time end_time).each do |endpoint|
      %w(not_before not_after).each do |crit|
        var = "#{endpoint}_#{crit}"
        value = params[var]
        unless value.blank?
          value = Time.local(value[:year], value[:month], value[:day], value[:hour])
          instance_variable_set("@#{var}", value)
          
          if crit == 'not_before'
            op = '>='
          else
            op = '<='
          end
          scope = scope.scoped(:conditions => ["#{Campaign.quote_identifier(endpoint)} #{op} ?", value])
        end
      end
    end
    
    @campaigns = scope.scoped(:order => 'campaign_code').all
    
    if request.xhr?
      render :partial => 'campaign_list'
    else
      prepare_index
      render :action => 'index'
    end
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
  
  def prepare_index
    @partners = Partner.all(:order => :name)
    @ad_inventory_sources = AdInventorySource.all(:order => :ais_code)
    @start_time_not_before ||= (Time.current.beginning_of_month).beginning_of_day
    @start_time_not_after ||= (Time.current + 1.day).beginning_of_day
    @end_time_not_before ||= (Time.current - 1.week).beginning_of_day
    @end_time_not_after ||= (Time.current + 1.year).beginning_of_day
  end
  
  def prepare_form
    @audiences = Audience.find(:all, :order => 'audience_code')
    @partners = Partner.find(:all, :order => 'name')
    @ad_inventory_sources = AdInventorySource.all(:order => 'name')
    @creatives = Creative.all(:order => 'description')
    @creative_sizes = CreativeSize.all(:order => 'common_name')
    @creative = Creative.new
    @new_creatives ||= []
    @new_partner ||= Partner.new
    
    unless request.post?
      if @new_partner && @new_partner.new_record?
        @new_partner.partner_code ||= Partner.generate_partner_code
      end
      if @campaign.new_record?
        @campaign.campaign_code ||= Campaign.generate_campaign_code
      end
    end
  end
  
  def update_campaign_objects
    @campaign.attributes = params[:campaign]

    if @campaign.partner.nil?
      @new_partner = Partner.new(params[:new_partner])
      @campaign.partner = @new_partner
    end
    
    if !params[:use_creatives].blank?
      @creatives = Creative.find(:all, :conditions => {:creative_code => params[:use_creatives].keys})
    else
      @creatives = []
    end
    
    # if no text fields are filled in for a creative, assume that
    # the user is not trying to add that creative
    @new_creatives = []
    checked_fields = %w(creative_code name media_type)
    unless (new_creatives = params[:creative]).blank?
      new_creatives.each do |attrs|
        if checked_fields.any? { |field| !attrs[field].blank? }
          @new_creatives << Creative.new(attrs)
        end
      end
    end
  end
  
  def save_campaign
    # if partner is invalid, check campaign validity anyway so that
    # error messages for campaign are displayed
    @campaign.valid?
    ok_to_save = (@new_partner.nil? || @new_partner.valid?) && @campaign.valid?
    @new_creatives.each do |creative|
      ok_to_save = creative.valid? && ok_to_save
    end
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
        @new_creatives.each do |creative|
          creative.save!
          @campaign.creatives << creative
        end
      end
    end
    ok_to_save
  end
end
