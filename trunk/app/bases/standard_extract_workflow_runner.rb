class StandardExtractWorkflowRunner < StandardWorkflowRunner
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
      params = ext_params.merge(version_params)
      params[:update_process_status] = true
      @workflow_class.new(params)
    end
    
    if ext_params[:extract] && workflows.length > 1
      workflow = workflows.detect do |workflow|
        workflow.should_download_url?(ext_params[:extract])
      end
      if workflow
        workflows = [workflow]
      else
        raise Workflow::FileSpecMismatch, "File url does not match any channel/input parameters"
      end
    end
    
    workflows.each do |workflow|
      if ext_params[:discover]
        script_str = "#{@name}-discover"
      else
        script_str = "#{@name}-extract"
      end
      params_str = "#{workflow.channel.name} #{workflow.date}"
      if workflow.hour
        params_str += '-%02d00' % workflow.hour
      end
      ProcessStatus.set(:script => script_str, :params => params_str) do
        if ext_params[:discover]
          files = workflow.discover
          files.each do |file|
            puts file
          end
        elsif ext_params[:extract]
          # Note: use extract here, not extract_if_fully_uploaded; attempts
          # to extract files which are not fully uploaded will raise exceptions
          # and/or cause the process to exit with an error.
          workflow.extract(ext_params[:extract])
        else
          workflow.run
        end
      end
    end
  end
  
  def handle_exception(exc)
    case exc
    when Workflow::FileAlreadyExtracted
      report_error("Error: file is already extracted")
      5
    when Workflow::FileExtractionInProgress
      report_error("Error: file extraction is in progress")
      6
    when Workflow::FileSpecMismatch
      report_error("Error: file does not match specification given")
      7
    when Workflow::FileNotReady
      report_error("Error: file is not ready to be extracted")
      8
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
