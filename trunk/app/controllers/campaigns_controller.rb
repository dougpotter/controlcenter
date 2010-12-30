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
    end

    # associate creatives with campaign
    params[:creatives].each do |number,attributes|
      @creative = Creative.new(attributes)
      @creative.campaigns << @campaign
      if @creative.save
        redirect_to new_campaign_path
      else
        render :text => "something wrong with creative"
        return
      end
    end

=begin
    @sync_params = {}
    # deal with audience source
    if params[:audience][:audience_type] == "Ad-Hoc"
      @sync_params = { "instance_type" => "m1.large", "instance_count" => "2" }
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
      @job = AppnexusSyncJob.new
      @job.name = 'appnexus-list-generate'
      @job_parameters = AppnexusSyncParameters.new(@sync_params || {})
      debugger
      if @job_parameters.valid?
        @job.parameters = @job_parameters.attributes
        @job.save!
        @job.run
      else
        render :text => "invalid appnexus sync job"
        return
      end 
    end

    # non-appnexus syncs
    for exchange in aises_for_inclusion
      params[:sync_rule][exchange.to_sym].each do |pixel_type, pixel|
        #build json object for submission to beacon API
      end
      # submit json object to beacon
    end
    render :text => "no create method for campaigns...yet"
  end
=end
  end
end
