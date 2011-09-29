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
      if !create_new_redirect_config(@partner, config, :type => "conversion")
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
      if !create_new_redirect_config(@partner, config, :type => "segment")
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

  def create_new_redirect_config(partner, config, options = {})
      audience = Audience.new(
        :description => config.name, 
        :audience_code => Audience.generate_audience_code)
      if !audience.save || !audience.save_beacon(partner.partner_code)
        audience.destroy
        flash[:notice] = "Error on audience save"
        return false
      end

      case options[:type]
      when "conversion"
        pixel = ConversionPixel.new(
          :name => config.name,
          :pixel_code => audience.audience_code,
          :partner_code => audience.partner.partner_code)
        if !pixel.save_apn
          audience.destroy
          pixel.destroy
          flash[:notice] = "Error on conversion pixel save"
          return false
        end
      when "segment"
        pixel = SegmentPixel.new(
          :name => config.name,
          :pixel_code => audience.audience_code,
          :partner_code => audience.partner.partner_code)
        if !pixel.save_apn
          audience.destroy
          pixel.destroy
          flash[:notice] = "Error on conversion pixel save"
          return false
        end
      end
       
      apn_conv_id = pixel.find_apn["id"]
      
      request_condition = RequestCondition.new(
        :request_url_regex => config.request_regex,
        :referer_url_regex => config.referer_regex,
        :audience_id => audience.beacon_id)
      if !request_condition.save_beacon
        audience.destroy
        pixel.destroy
        flash[:notice] = "Error on request condition save"
        return false
      end

      case options[:type]
      when "conversion"
        sync_rule = SyncRule.new(
          :audience_id => audience.beacon_id,
          :sync_period => 7,
          :nonsecure_add_pixel => 
            SyncRule.apn_nonsecure_add_conversion(
              partner.partner_code, 
              audience.audience_code),
          :secure_add_pixel => 
            SyncRule.apn_secure_add_conversion(
              partner.partner_code, 
              audience.audience_code))
      when "segment"
        sync_rule = SyncRule.new(
          :audience_id => audience.beacon_id,
          :sync_period => 7,
          :nonsecure_add_pixel => 
            SyncRule.apn_nonsecure_add_segment(audience.audience_code),
          :secure_add_pixel => 
            SyncRule.apn_secure_add_segment(audience.audience_code))
      end
      if !sync_rule.save_beacon
        audience.destroy
        pixel.destroy
        request_condition.destroy
        @partners = Partner.all
        flash[:notice] = "Error on sync rule save"
        return false
      end

    return true
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
        create_new_redirect_config(
          Partner.find(params[:id]), conv_config, :type => "conversion"
        )
      elsif destroy_config?(conv_config)
        destroy_config(conv_config, 'conversion')
      else 
        update_config(conv_config, 'conversion')
      end
    end
    retargeting_configs = extract_retargeting_config_params
    for retargeting_config in retargeting_configs
      if new_config?(retargeting_config)
        create_new_redirect_config(
          Partner.find(params[:id]), retargeting_config, :type => "segment"
        )
      elsif destroy_config?(retargeting_config)
        destroy_config(retargeting_config, 'segment')
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

  def destroy_config(config, config_type)
    audience = Audience.find_by_audience_code(config["pixel_code"])
    if config_type == 'conversion'
      ConversionPixel.new( 
        :partner_code => audience.partner.partner_code,
        :pixel_code => audience.audience_code).delete_apn
    elsif config_type == 'segment'
      SegmentPixel.new( 
        :partner_code => audience.partner.partner_code,
        :pixel_code => audience.audience_code,
        :member_id => APN_CONFIG["member_id"]).delete_apn
    end
    request_condition = 
      Beacon.new.request_conditions(audience.beacon_id).request_conditions.first
    Beacon.new.delete_request_condition(
      audience.beacon_id,
      request_condition['id'])
    for sync_rule in Beacon.new.sync_rules(audience.beacon_id).sync_rules
      Beacon.new.delete_sync_rule(audience.beacon_id, sync_rule['id'])
    end
    audience.destroy if audience
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

