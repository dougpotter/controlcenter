class ActionTagsController < ApplicationController
  def sid
    render :text => ActionTag.generate_sid
  end
end
