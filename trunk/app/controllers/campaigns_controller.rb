class CampaignsController < ApplicationController
  def new
    @campaign = Campaign.new
    @line_items = LineItem.all
    @campaign_types = AudienceSource.all(:select => "DISTINCT(type)")
    @aises = [ AdInventorySource.find_by_ais_code("ApN") ]
    @creative_sizes = CreativeSize.all
    @creative = Creative.new
    params[:line_item_id] ? @selected_line_item = params[:line_item_id].to_i : nil
  end

  def create
    # build new campaign
    params[:campaign][:line_item] = LineItem.find(params[:campaign][:line_item])
    @campaign = Campaign.new(params[:campaign])
    if !@campaign.save
      redirect_to(new_campaign_path, :notice => "failed to save campaign")
      return
    end

    if @audience = Audience.find_by_audience_code(params[:audience][:audience_code])
      # duplicate audience code
      redirect_to(
        new_campaign_path, 
        :notice => "audience code #{@audience.audience_code} already exists," +
        " please choose a new one"
      )
      return
    else
      # build new audience and source and associate them
      @audience_source = source_from_params
      @audience = Audience.new(params[:audience])
      @audience.update_source(@audience_source)
      if !@campaign.update_attributes({:audience => @audience})
        redirect_to(new_campaign_path, :notice => "failed to save audience")
        return
      end
    end

    # associate creatives with campaign
    if !params[:creatives].nil?
      params[:creatives].each do |number,attributes|
        @creative = Creative.new(attributes)
        @creative.campaigns << @campaign
        if !@creative.save
          redirect_to(
            campaign_management_index_path, 
            :notice => "failed to save one or more creatives"
          )
          return
        end
      end
    end

    if params[:aises_for_sync]
      # deal with audience source
      @sync_params = {}

      if @audience_source.class_name == "AdHocSource"
        @sync_params["s3_xguid_list_prefix"] = @audience_source.s3_location
        @sync_params["partner_code"] = @campaign.partner.partner_code
        @sync_params["audience_code"] = params[:audience][:audience_code]
        @sync_params["appnexus_segment_id"] = 
          params[:sync_rules][:ApN][:apn_segment_id]
      elsif @audience_source.class_name == "RetargetingSource"
        render :text => "retargeting audience not yet supported"
        return
      else
        render :text => "audience source not supported"
        return
      end


      if @apn_params = params[:sync_rules].delete("ApN")
        # sync audience with ApN
        @sync_params.update(@apn_params)
        if !create_and_run_apn_sync_job('appnexus-list-generate', @sync_params)
          render :text => "invalid appnexus sync job"
          return
        end
      end
    end

    redirect_to(
      campaign_path(@campaign), 
      :notice => "campaign successfully created")
  end

  def edit
    @campaign = Campaign.find(params[:id])
    @line_items = LineItem.all
    @selected_line_item = @campaign.line_item.id
    @aises = [ AdInventorySource.find_by_ais_code("ApN") ]
  end

  def matching_source_types?(campaign, source)
    if campaign.audience.latest_source.class.to_s ==source.class.to_s
      return true
    end
  end

  def update
    @campaign = Campaign.find(params[:id])
    params[:campaign][:line_item] = 
      LineItem.find(params[:campaign][:line_item])

    # process audience source params
    params[:audience][:audience_source] = source_from_params
      @campaign.audience.update_source(params[:audience][:audience_source])

    # process audience description
    @campaign.audience.update_attributes(
      :description => params[:audience][:description]
    )

    # process segment ids
    if params[:aises_for_sync]
      for ais_code in params[:aises_for_sync]
        ais = AdInventorySource.find_by_ais_code(ais_code)
        @campaign.configure_ais(ais, params[:sync_rules][ais][:appnexus_segment_id])
      end
    end

    if @campaign.update_attributes(params[:campaign])
        redirect_to(
          campaign_path(@campaign.id), 
          :notice => "campaign successfully updated"
        )
    else
      notice = "campaign update failed: "
      @campaign.errors.each do |attr,msg|
        notice += attr + " " + msg + ";"
      end
      notice = notice[0..-2]
      redirect_to(
        edit_campaign_url, 
        { :id => @campaign.id, :notice => notice }
      )
    end
  end

  def destroy
    @campaign = Campaign.destroy(params[:id])
    redirect_to(campaign_management_index_path, :notice => "campaign deleted")
  end

  def show
    @campaign = Campaign.find(params[:id])
  end

  def source_from_params
    source_type = params[:audience][:audience_source].delete(:type)
    case source_type
    when "Ad-Hoc"
      @audience_source = 
        AdHocSource.new(params[:audience].delete(:audience_source))
    when "Retargeting"
      @audience_source = 
        RetargetingSource.new(params[:audience].delete(:audience_source))
    end
    return @audience_source
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
end
