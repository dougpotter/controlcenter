class PartnersController < ApplicationController

  def index
    @partners = Partner.find(:all)
  end

  def new
    if !Beacon.new.alive?
      flash[:notice] = "Warning: Beacon is dead." unless !flash[:notice].blank?
    end
    @partners = Partner.all
    @partner = Partner.new
  end

  def create
    @action_tags = extract_action_tags
    @conversion_configs = extract_conversion_configs
    @retargeting_configs = extract_retargeting_configs
    @partner = Partner.new(params[:partner])

    if !Beacon.new.alive?
      @partner.action_tags.build(@action_tags.map { |a| a.attributes })
      @partner.temp_conversion_configurations = (@conversion_configs)
      @partner.temp_retargeting_configurations = (@retargeting_configs)
      @partners = Partner.all
      flash[:notice] = "Beacon is offline! Can't save new partner."
      render :action => "new"
      return
    end

    # if partner doesn't save, bail
    if !@partner.save || !@partner.save_apn
      @partner.destroy
      @partner.action_tags.build(@action_tags.map { |a| a.attributes })
      @partner.temp_conversion_configurations = (@conversion_configs)
      @partner.temp_retargeting_configurations = (@retargeting_configs)
      @partners = Partner.all
      render :action => "new"
      return
    end

    #associate action tags with new partner
    for action_tag in @action_tags
      if @partner.action_tags << action_tag
        # do nothing
      else
      @partner = @partner.destroy_and_attach(
        @action_tags, @conversion_configs, @retargeting_configs
      )
        @partners = Partner.all
        flash[:notice] = "Invalid action tag"
        render :action => "new"
        return
      end
    end

    for config in @conversion_configs
      if !ConversionConfiguration.create(@partner, config)
        @partner = @partner.destroy_and_attach(
          @action_tags, @conversion_configs, @retargeting_configs
        )
        @partners = Partner.all
        flash[:notice] = "Invalid conversion config"
        render :action => "new"
        return
      end
    end

    for config in @retargeting_configs
      if !RetargetingConfiguration.create(@partner, config)
        @partner = @partner.destroy_and_attach(
          @action_tags, @conversion_configs, @retargeting_configs
        )
        @partners = Partner.all
        flash[:notice] = "Invalid retargeting config"
        render :action => "new"
        return
      end
    end

    redirect_to(
      partner_path(@partner.id)
    )
  end

  def show
    @partner = Partner.find(params[:id])
    if !Beacon.new.alive?
      flash[:notice] = "Beacon is dead. Can't show details for #{@partner.name}"
      redirect_to new_partner_path
    end
  end

  def edit
    @partner = Partner.find(params[:id])
    @partner.temp_conversion_configurations = @partner.conversion_configurations
    @partner.temp_retargeting_configurations = @partner.retargeting_configurations
    if !Beacon.new.alive?
      flash[:notice] = "Beacon is dead. Can't edit #{@partner.name}"
      redirect_to new_partner_path
    end
  end

  def update
    @partner = Partner.find(params[:id])

    if !Beacon.new.alive?
      flash[:notice] = "Beacon is dead. Can't update #{@partner.name}"
      redirect_to new_partner_path
      return
    end

    notice = notice_on_success(@partner)
    handle_redirect_configurations
    if @partner.update_attributes(params[:partner])
      flash[:notice] = notice
      redirect_to(partner_path(@partner))
    else
      flash[:notice] = "Update failed"
      render :action => 'edit', :id => @partner
    end
  end

  def notice_on_success(partner)
    notice = Builder::XmlMarkup.new
    notice.ul do |b|
      if params[:partner][:action_tags_attributes]
        for attrs in params[:partner][:action_tags_attributes].values
          if attrs["_destroy"]
            notice += "<li>#{ActionTag.find(attrs[:id]).name} tag removed</li>"
          end
        end
      end
    end
    return notice.class
  end

  def destroy
    @partner = Partner.find(params[:id])

    if !Beacon.new.alive?
      flash[:notice] = "Beacon is dead. Can't destroy #{@partner.name}"
      redirect_to new_partner_path
      return
    end

    @partner.destroy

    redirect_to(new_partner_path, :notice => "advertiser deleted")
  end

  def extract_action_tags
    # this junky code is necessary because of this problem:
    # http://bit.ly/stack_overflow_on_nested_forms
    action_tags_attrs = params[:partner].delete("action_tags_attributes")

    @action_tags = []
    if action_tags_attrs
      for attr_hash in action_tags_attrs.values
        @action_tags << ActionTag.new(attr_hash)
      end
    end
    return @action_tags
  end

  def extract_conversion_configs
    if config_hashes = 
      params[:partner].delete("conversion_configurations_attributes")
      return config_hashes.values.map { |conv_conf|
        ConversionConfiguration.new(conv_conf)
      } 
    else
      return []
    end
  end

  def extract_retargeting_configs
    if config_hashes = 
      params[:partner].delete("retargeting_configurations_attributes")
      return config_hashes.values.map { |retargeting_conf|
        RetargetingConfiguration.new(retargeting_conf)
      } 
    else
      return []
    end
  end

  def extract_conv_config_params 
    if conv_configs = params[:partner].
      delete("conversion_configurations_attributes")
      return conv_configs.values.map { |conv_config| Hashie::Mash.new(conv_config) }
    else
      return []
    end
  end

  def extract_retargeting_config_params
    if retargeting_configs = params[:partner].
      delete("retargeting_configurations_attributes")
      return retargeting_configs.values.map { |retargeting_config| Hashie::Mash.new(retargeting_config) }
    else
      return []
    end
  end

  def handle_redirect_configurations
    conv_configs = extract_conv_config_params
    for conv_config in conv_configs
      if new_config?(conv_config)
        ConversionConfiguration.create(Partner.find(params[:id]), conv_config)
      elsif destroy_config?(conv_config)
        ConversionConfiguration.destroy(conv_config)
      else 
        update_config(conv_config, 'conversion')
      end
    end
    retargeting_configs = extract_retargeting_config_params
    for retargeting_config in retargeting_configs
      if new_config?(retargeting_config)
        RetargetingConfiguration.create(Partner.find(params[:id]), conv_config)
      elsif destroy_config?(retargeting_config)
        RetargetingConfiguration.destroy(retargeting_config)
      else 
        update_config(retargeting_config, 'segment')
      end
    end
  end

  def new_config?(config)
    Audience.find_by_audience_code(config["pixel_code"]).nil?
  end

  def destroy_config?(config)
    config["_destroy"] == "true"
  end

  def update_config(config, config_type)
    audience = Audience.find_by_audience_code(config["pixel_code"])
    audience.update_attributes(:description => config["name"])
    Beacon.new.update_audience(audience.beacon_id, config["name"], 0)
    if config_type == 'conversion'
      ConversionPixel.new( 
        :name => config["name"],
        :partner_code => audience.partner.partner_code,
        :pixel_code => audience.audience_code).update_attributes_apn
    elsif config_type == 'segment'
      SegmentPixel.new( 
        :name => config["name"],
        :partner_code => audience.partner.partner_code,
        :pixel_code => audience.audience_code,
        :member_id => APN_CONFIG["member_id"]).update_attributes_apn
    end
    request_condition = 
      Beacon.new.request_conditions(audience.beacon_id).request_conditions.first
    Beacon.new.update_request_condition(
      audience.beacon_id,
      request_condition['id'],
      :request_url_regex => config["request_regex"],
      :referer_url_regex => config["referer_regex"])
    # can't update SyncRule
    # potentially change sync period, eventually
  end
end

