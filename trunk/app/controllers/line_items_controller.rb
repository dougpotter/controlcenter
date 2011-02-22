class LineItemsController < ApplicationController
  def new
    @line_item = LineItem.new
    @line_items = LineItem.all
    @partners = Partner.all
  end

  def create
    @line_item = LineItem.new(params[:line_item])
    @creatives = params[:creatives]
    if @line_item.save
      redirect_to(new_line_item_path, :notice => "line item successfully saved")
    else
      redirect_to(new_line_item_path)
    end
  end

  def update
    @line_item = LineItem.find(params[:id])
    if @line_item.update_attributes(params[:line_item])
      redirect_to(new_line_item_path, :notice => "line item successfully updated")
    else
      redirect_to(edit_line_item_path(params[:id]))
    end
  end

  def edit
    @line_item = LineItem.find(params[:id])
    @partners = Partner.all
  end
end
