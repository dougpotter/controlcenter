class PartnersController < ApplicationController

  def index
    @partners = Partner.find(:all)
  end

  def new
    @partners = Partner.all
    @partner = Partner.new
  end

  def create
    @action_tags = extract_action_tags
    @conversion_configs = extract_conversion_configs
    @partner = Partner.new(params[:partner])

    # if partner doesn't save, bail
    if !@partner.save || !@partner.save_apn
      @partner.destroy
      @template_partner = Partner.new(@partner.attributes)
      for error in @partner.errors.on_base
        @template_partner.errors.add_to_base(error)
      end
      @template_partner.action_tags = @action_tags
      @template_partner.temp_conversion_configurations = @conversion_configs
      @partner = @template_partner
      @partners = Partner.all
      render :action => "new"
      return
    end

    #associate action tags with new partner
    for action_tag in @action_tags
      if @partner.action_tags << action_tag
        # do nothing
      else
        @partner.destroy
        @partner = Partner.new(@partner.attributes)
        @partners = Partner.all
        flash[:notice] = "Invalid action tag"
        render :action => "new"
        return
      end
    end

    for config in @conversion_configs
      if !create_new_conversion_config(@partner, config)
        @partner.destroy
        @partner = Partner.new(@partner.attributes)
        @partners = Partner.all
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
  end

  def edit
    @partner = Partner.find(params[:id])
  end

  def update
    @partner = Partner.find(params[:id])

    notice = noticeOnSuccess(@partner)
    handle_conversion_configurations
    if @partner.update_attributes(params[:partner])
      flash[:notice] = notice
      redirect_to(partner_path(@partner.id))
    else
      flash[:notice] = "Update failed"
      render :action => 'edit', :id => @partner
    end
  end

  def destroy
    @partner = Partner.destroy(params[:id])
    redirect_to(new_partner_path, :notice => "advertiser deleted")
  end

  def extract_action_tags
    # this junky code is necessary because of this problem:
    # http://bit.ly/stack_overflow_on_nested_forms
    action_tags_attrs = params[:partner].delete("action_tags_attributes")

    @action_tags = []
    if action_tags_attrs
      for attr_hash in action_tags_attrs.values
        if !attr_hash.has_value?('')
          @action_tags << ActionTag.new(attr_hash)
        end
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

  def create_new_conversion_config(partner, config)
      audience = Audience.new(
        :description => config.name, 
        :audience_code => Audience.generate_audience_code)
      if !audience.save || !audience.save_beacon(partner.partner_code)
        audience.destroy
        flash[:notice] = "Error on audience save"
        return false
      end

      apn_conversion_pixel = ConversionPixel.new(
        :name => config.name,
        :pixel_code => audience.audience_code,
        :partner_code => audience.partner.partner_code)
      if !apn_conversion_pixel.save_apn
        audience.destroy
        apn_conversion_pixel.destroy
        flash[:notice] = "Error on conversion pixel save"
        return false
      end
        
      apn_conv_id = apn_conversion_pixel.find_apn["id"]
      
      request_condition = RequestCondition.new(
        :request_url_regex => config.request_regex,
        :referer_url_regex => config.referer_regex,
        :audience_id => audience.beacon_id)
      if !request_condition.save_beacon
        audience.destroy
        apn_conversion_pixel.destroy
        flash[:notice] = "Error on request condition save"
        return false
      end

      sync_rule = SyncRule.new(
        :audience_id => audience.beacon_id,
        :sync_period => 7,
        :nonsecure_add_pixel => 
          SyncRule.apn_nonsecure_add_from_pixel_code(
            partner.partner_code, 
            audience.audience_code),
        :secure_add_pixel => 
          SyncRule.apn_secure_add_from_pixel_code(
            partner.partner_code, 
            audience.audience_code))
      if !sync_rule.save_beacon
        audience.destroy
        apn_conversion_pixel.destroy
        request_condition.destroy
        @partners = Partner.all
        flash[:notice] = "Error on sync rule save"
        return false
      end

    return true
  end

  def noticeOnSuccess(partner)
    notice = Builder::XmlMarkup.new
    notice.ul do |b|
      if params[:partner][:action_tags_attributes]
        b.li("#{ActionTag.find(attrs[:id]).name} tag removed")
      end
    if params[:partner][:action_tags_attributes]
      for attrs in params[:partner][:action_tags_attributes].values
        if attrs["_destroy"]
          notice += "<li>#{ActionTag.find(attrs[:id]).name} tag removed</li>"
        end
      end
    end
    end
    return  + builder
  end

  def extract_conv_config_params 
    if conv_configs = params[:partner].
      delete("conversion_configurations_attributes")
      return conv_configs.values.map { |conv_config| Hashie::Mash.new(conv_config) }
    else
      return []
    end
  end

  def handle_conversion_configurations
    conv_configs = extract_conv_config_params
    for conv_config in conv_configs
      if new_config?(conv_config)
        create_new_conversion_config(Partner.find(params[:id]), conv_config)
      elsif destroy_config?(conv_config)
        destroy_config(conv_config)
      else 
        update_config(conv_config)
      end
    end
  end

  def new_config?(conv_config)
    Audience.find_by_audience_code(conv_config["pixel_code"]).nil?
  end

  def destroy_config?(conv_config)
    conv_config["_destroy"] == "true"
  end

  def destroy_config(conv_config)
    audience = Audience.find_by_audience_code(conv_config["pixel_code"])
    ConversionPixel.new( 
      :partner_code => audience.partner.partner_code,
      :pixel_code => audience.audience_code).delete_apn
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

  def update_config(conv_config)
        audience = Audience.find_by_audience_code(conv_config["pixel_code"])
        audience.update_attributes(:description => conv_config["name"])
        Beacon.new.update_audience(audience.beacon_id, conv_config["name"], 0)
        ConversionPixel.new( 
          :name => conv_config["name"],
          :partner_code => audience.partner.partner_code,
          :pixel_code => audience.audience_code).update_attributes_apn
        request_condition = 
          Beacon.new.request_conditions(audience.beacon_id).request_conditions.first
        Beacon.new.update_request_condition(
          audience.beacon_id,
          request_condition['id'],
          :request_url_regex => conv_config["request_regex"],
          :referer_url_regex => conv_config["referer_regex"])
        # can't update SyncRule
        # potentially change sync period, eventually
  end
end

