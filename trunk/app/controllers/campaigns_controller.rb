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
    @campaign = Campaign.new(params[:campaign])
    if !@campaign.save
      render :text => "campaign failed to save"
      return
    end

    # associate creatives with campaign
    params[:creatives].each do |number,attributes|
      @creative = Creative.new(attributes)
      @creative.campaigns << @campaign
      if !@creative.save
        render :text => "failed to save creative"
        return
      end
    end

    @sync_params = {}
    # deal with audience source
    if params[:audience][:audience_type] == "Ad-Hoc"
      @sync_params["s3_xguid_list_prefix"] = params[:audience_source][:s3_location]
      @sync_params["partner_code"] = @campaign.partner.partner_code
      @sync_params["audience_code"] = params[:audience_source][:audience_code]
      @sync_params["appnexus_segment_id"] = params[:sync_rule][:ApN][:apn_segment_id]
    elsif params[:audience][:audience_type] == "Retargeting"
      render :text => "retargeting audience not yet supported"
      return
    else
      render :text => "audience source not supported"
      return
    end


    # sync audience with ApN
    @aises_for_inclusion = params[:aises_for_sync]
    if @aises_for_inclusion.delete("ApN")
      if save_and_run_apn_sync_job('appnexus-list-generate', @sync_params)
        render :text => "invalid appnexus sync job"
        return
      end
    end

    redirect_to new_campaign_path
  end
end
