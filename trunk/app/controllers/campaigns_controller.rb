class CampaignsController < ApplicationController
  def new
    @campaign = Campaign.new
    @campaign.campaign_code = Campaign.generate_campaign_code
    @line_items = LineItem.all
    @audience = Audience.new
    @audience_source = AdHocSource.new
    @aises = [ AdInventorySource.find_by_ais_code("ApN") ]
    @campaign_types = AudienceSource.all(:select => "DISTINCT(type)").sort
    @creative_sizes = CreativeSize.all
    @creative = Creative.new
    params[:line_item_id] ? @selected_line_item = params[:line_item_id].to_i : nil
  end

  def create
    @campaign = Campaign.new(params[:campaign])
    for creative in @campaign.creatives
      creative.partner_id = @campaign.line_item.partner.id
    end
    if !@campaign.save
      @line_items = LineItem.all
      @aises = [ AdInventorySource.find_by_ais_code("ApN") ]
      @campaign_types = AudienceSource.all(:select => "DISTINCT(type)")
      @creative_sizes = CreativeSize.all
      @creative = Creative.new
      render :new
      return
    end

    # handle audience sync
    if ais_codes = params[:aises_for_sync]
      for ais_code in ais_codes
        ais = AdInventorySource.find_by_ais_code(ais_code)
        @campaign.configure_ais(ais, params[:sync_rules][ais_code][:segment_id])
      end 
    end

    redirect_to(
      campaign_path(@campaign), 
      :notice => "campaign successfully created")
  end

  def edit
    @new_campaign = Campaign.new
    @campaign = Campaign.find(params[:id])
    @partner = @campaign.partner
    @line_items = LineItem.all
    @selected_line_item = @campaign.line_item.id
    @creative = Creative.new
    @creatives = @campaign.creatives
    @creative_sizes = CreativeSize.all
    @aises = [ AdInventorySource.find_by_ais_code("ApN") ]
    @campaign_types = AudienceSource.all(:select => "DISTINCT(type)")
    @audience_sources = @campaign.audience.sources_in_order
    @audience_source = @campaign.audience.latest_source
  end

  def update
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(params[:campaign])

    # process segment ids
    params[:sync_rules].each do |ais_code, rule|
      ais = AdInventorySource.find_by_ais_code(ais_code)
      if params[:aises_for_sync] && params[:aises_for_sync].member?(ais_code)
        @campaign.configure_ais(ais, rule[:segment_id])
      else
        @campaign.unconfigure_ais(ais)
      end
    end

    redirect_to(
      campaign_path(@campaign),
      :notice => "campaign updated")
  end

  def destroy
    @campaign = Campaign.destroy(params[:id])
    redirect_to(campaign_management_index_path, :notice => "campaign deleted")
  end

  def show
    @campaign = Campaign.find(params[:id])
    @creatives = @campaign.creatives
  end

  def options_filtered_by_partner
    if !params[:partner_id].blank?
      @campaigns = Campaign.find(
        :all, 
        :joins => { :line_item => :partner }, 
        :conditions => { "partners.id" => params[:partner_id] }
      )
    else
      @campaigns = Campaign.all
    end

    render :partial => "options_for_select", :locals => { :campaigns => @campaigns }
  end

  def filtered_edit_table
    if all = params[:ALL]
      @filtered_campaigns = Campaign.all
    elsif partner_name = params[:partner_name]
      @filtered_campaigns = Campaign.find(
        :all, 
        :joins => { :line_item => :partner },  
        :conditions => [ "partners.name = ? ", [partner_name] ])
    elsif campaign_name = params[:name]
      @filtered_campaigns = [ Campaign.find_by_name(campaign_name) ]
    end 

    @campaigns = Campaign.all

    render :partial => "/layouts/edit_table", :locals => {
      :collection => @filtered_campaigns,
      :collection_for_filter_menu => @campaigns,
      :header_names => [ 
        "Partner", 
        "Campaign Name", 
        "Code", 
        "Start Date", 
        "End Date" ],
      :fields => [
        "partner_name", 
        "name", 
        "campaign_code", 
        "pretty_start_time", 
        "pretty_end_time" ],
      :filter_menus => [ 0, 1 ], 
      :width => "650", 
      :class_name => "campaigns_summery",
      :edit_path => campaign_path(1) }
  end
end
