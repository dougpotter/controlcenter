require 'xgw/workflow_dictionary'

HttpParticipant
PageParsingParticipant
GzipParticipant
S3Participant
WaitingParticipant
WaitingGlueParticipant
ClearspringParticipant
ClearspringGlueParticipant

class ClearspringWorkflows < Xgw::WorkflowDictionary
  def define_workflows
    define_workflow :clearspring_hourly_discovery do
      participant 'Clearspring:build_data_source_url'
      participant 'ClearspringGlue:fetch_data_source_url_directory_listing'
      participant 'Http:fetch_directory_listing'
      participant 'ClearspringGlue:parse_directory_listing'
      participant 'PageParsing:parse_nginx_httpd_file_list'
      participant 'ClearspringGlue:absolutize_file_urls'
      participant 'Clearspring:mkdir_download_dirname'
      participant 'Clearspring:launch_file_url_downloads'
      _if :test => "${input.wait} == true" do
        sequence do
          participant 'WaitingGlue:prepare_jobs_to_wait_for'
          participant 'Waiting:wait_for_jobs'
        end
      end
    end
    
    define_workflow :clearspring_file_download do
      participant 'Clearspring:build_file_download_url'
      participant 'Http:fetch_file'
      participant 'Clearspring:mkdir_split_dirname'
      participant 'Clearspring:launch_split'
      _if :test => "${input.wait} == true" do
        sequence do
          participant 'WaitingGlue:prepare_job_to_wait_for'
          participant 'Waiting:wait_for_jobs'
        end
      end
    end
    
    define_workflow :clearspring_file_split do
      participant 'Gzip:split_file'
      participant 'ClearspringGlue:prepare_split_files_for_upload'
      participant 'Clearspring:launch_uploads'
      _if :test => "${input.wait} == true" do
        sequence do
          participant 'WaitingGlue:prepare_jobs_to_wait_for'
          participant 'Waiting:wait_for_jobs'
        end
      end
    end
    
    define_workflow :clearspring_file_upload do
      participant 'Clearspring:build_upload_path'
      participant 'ClearspringGlue:prepare_file_upload'
      participant 'S3:upload_file'
    end
  end
end
