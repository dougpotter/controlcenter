module AppnexusHelper
  def status_name(status)
    %w(None Created Processing Completed)[status]
  end
end
