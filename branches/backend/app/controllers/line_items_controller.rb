class LineItemsController < ApplicationController
  def new
    @line_item = LineItem.new
    @partners = Partner.all
    @creative_sizes = CreativeSize.all
    @creative = Creative.new
  end

  def create
    @line_item = LineItem.new(params[:line_item])
    @creatives = params[:creatives]
    if @line_item.save
      redirect_to new_line_item_path
    end
  end
end
