class StandardVerifyWorkflowRunner < StandardWorkflowRunner
  def perform(ext_params)
    versions = ext_params[:selected_channels].map do |channel|
      {:channel => channel}
    end
    if ext_params[:hours]
      versions.map! do |version|
        ext_params[:hours].map do |hour|
          version.merge(:hour => hour)
        end
      end.flatten!
    end
    workflows = versions.map do |version_params|
      params = settings.merge(ext_params).to_hash
      %w(
        check_sizes check_sizes_strictly check_sizes_exactly check_content
        record trust_recorded quiet
      ).each do |key|
        key = key.to_sym
        params[key] = ext_params[key]
      end
      params.update(version_params)
      params[:update_process_status] = false
      params[:logger] = ext_params[:logger]
      @workflow_class.new(params)
    end
    
    workflows.each do |workflow|
      if ext_params[:check_listing]
        workflow.check_listing
      elsif ext_params[:check_consistency]
        workflow.check_consistency
      else
        if ext_params[:check_our_existence]
          workflow.check_our_existence
        end
        if ext_params[:check_their_existence]
          workflow.check_their_existence
        end
      end
    end
  end
  
  def handle_exception(exc)
    case exc
    when HttpClient::HttpError
      report_error("Transfer error: #{exc.message} @ #{exc.url} [#{exc.code}]")
      9
    when HttpClient::BaseError
      forward_unhandled_exception(exc, :message => "Unhandled transfer error: #{exc.message} @ #{exc.url}")
      10
    else
      super
    end
  end
end
