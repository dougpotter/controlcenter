class PartnersController < ApplicationController

  def index
    @partners = Partner.find(:all)
  end

  def new
    @partners = Partner.all
    @partner = Partner.new
    @action_tag_for_form_builder = ActionTag.new
  end

  def extract_action_tags
    # this junky code is necessary because of this problem:
    # http://stackoverflow.com/questions/1209200/how-to-create-nested-objects-using-accepts-nested-attributes-for
    action_tags_attrs = params[:partner].delete("action_tags_attributes")

    @action_tags = []
    if action_tags_attrs
      for attr_hash in action_tags_attrs.values
        if non_blank?(attr_hash)
          @action_tags << ActionTag.new(attr_hash)
        end
      end
    end
    return @action_tags
  end

  def non_blank?(hash)
    answer = true
    for val in hash.values
      answer = false if val.blank?
    end
    return answer
  end

  def create
    @action_tags = extract_action_tags

    @partner = Partner.new(params[:partner])

    # if partner doesn't save, bail
    if !@partner.save
      @partners = Partner.all
      render :action => "new"
      return
    end

    #associate action tags with new partner
    for action_tag in @action_tags
      action_tag.partner_id = @partner.id
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
    redirect_to(
      new_partner_path,
      :notice => "#{@partner.name} successfully created"
    )
  end

  def edit
    @partner = Partner.find(params[:id])
  end

  def noticeOnSuccess(partner)
    notice = "#{Partner.name} successfully updated"
    notice += "<ul>"
    for attrs in params[:partner][:action_tags_attributes].values
      if attrs["_destroy"]
        notice += "<li>#{ActionTag.find(attrs[:id]).name} tag removed</li>"
      end
    end
    notice += "</ul>"
    return notice
  end

  def update
    @partner = Partner.find(params[:id])

    notice = noticeOnSuccess(@partner)
    if @partner.update_attributes(params[:partner])
      flash[:notice] = notice
      redirect_to(:action => 'new')
    else
      flash[:notice] = "Update failed"
      render :action => 'edit', :id => @partner
    end
  end

  def destroy
    @partner = Partner.destroy(params[:id])
    redirect_to(new_partner_path, :notice => "advertiser deleted")
  end
end
