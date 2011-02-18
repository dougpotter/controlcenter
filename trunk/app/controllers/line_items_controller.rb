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
      notice = "line item failed to save:\n"
      @line_item.errors.each do |attr, msg|
        notice += "#{attr} #{msg}\n"
      end
      redirect_to(new_line_item_path, :notice => notice)
    end
  end
end
