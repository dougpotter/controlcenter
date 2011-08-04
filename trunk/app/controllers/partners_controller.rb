class PartnersController < ApplicationController

  def index
    @partners = Partner.find(:all)
  end

  def new
    @partners = Partner.all
    @partner = Partner.new
    @action_tags = ActionTag.new 
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
        @partners = Partner.all
        render :action => "new", :notice => "invalid action tag"
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

  def update
    @partner = Partner.find(params[:id])
    if @partner.update_attributes(params[:partner])
      redirect_to(
        :action => 'new',
        :notice => "#{@partner.name} successfully updated"
      )
    else
      render :action => 'edit', :id => @partner
    end
  end

  def destroy
    @partner = Partner.destroy(params[:id])
    redirect_to(new_partner_path, :notice => "advertiser deleted")
  end
end
