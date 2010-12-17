# Rename this controller to AppnexusSyncController if other actions are needed.
class AppnexusController < ApplicationController
  def index
    @jobs = AppnexusSyncJob.all(:order => 'created_at desc')
  end
end
