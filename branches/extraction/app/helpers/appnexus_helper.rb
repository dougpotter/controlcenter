module AppnexusHelper
  def appnexus_status_name(status)
    %w(None Created Processing Completed Failed)[status]
  end
end
