class CampaignsController < ApplicationController
  def new
    @campaign = Campaign.new
    @line_items = LineItem.all
    @campaign_types = [ "Ad-Hoc", "Retargeting" ]
    #@aises = AdInventorySource.all
    @aises = [ AdInventorySource.find_by_ais_code("ApN") ]
    @creative_sizes = CreativeSize.all
    @creative = Creative.new
  end

  def create
    # build new campaign
    params[:campaign][:line_item] = LineItem.find(params[:campaign][:line_item])
    @campaign = Campaign.new(params[:campaign])
    if !@campaign.save
      redirect_to(new_campaign_path, :notice => "failed to save campaign")
      return
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
      if params[:audience][:audience_type] == "Ad-Hoc"
        @sync_params["s3_xguid_list_prefix"] = 
          params[:audience_source][:s3_location]
        @sync_params["partner_code"] = @campaign.partner.partner_code
        @sync_params["audience_code"] = params[:audience_source][:audience_code]
        @sync_params["appnexus_segment_id"] = 
          params[:sync_rules][:ApN][:apn_segment_id]
      elsif params[:audience][:audience_type] == "Retargeting"
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
      campaign_management_index_path, 
      :notice => "campaign successfully created")
  end

  def edit
    @campaign = Campaign.find(params[:id])
    @line_items = LineItem.all
    @selected_line_item = @campaign.line_item.id
    @campaign_types = [ "Ad-Hoc", "Retargeting" ]
  end

  def update
    @campaign = Campaign.find(params[:id])

    if @campaign.update_attributes(params[:campaign])
      redirect_to(
        campaign_management_index_path, 
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
end
