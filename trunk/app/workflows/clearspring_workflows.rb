HttpParticipant
PageParsingParticipant
GzipParticipant
S3Participant
WaitingParticipant
WaitingGlueParticipant
ClearspringParticipant
ClearspringGlueParticipant

# Easy way to make these workflows fail:
#
# 1. Point to nonexistent download server, or point to local server
#    which is not running.
# 2. Point to nonexistent s3 server, or point to default server while
#    not on network, or point to local s3 server which is not running.
#
# Note: ruby on freebsd does not properly handle running out of disk
# (no exceptions are raised, writes are effectively silently ignored)
# so running out of disk is not a good test of anything at least on
# freebsd.

class ClearspringWorkflows < WorkflowDictionary
  def define_workflows
    define_workflow :clearspring_hourly_discovery do
      participant 'Clearspring:build_data_source_url'
      participant 'ClearspringGlue:fetch_data_source_url_directory_listing'
      _if :test => '${input.lock} == true' do
        participant 'Http:fetch_directory_listing', :lock => 'clearspring-list'
      end
      _if :test => '${input.lock} == false' do
        participant 'Http:fetch_directory_listing'
      end
      participant 'ClearspringGlue:parse_directory_listing'
      participant 'PageParsing:parse_nginx_httpd_file_list'
      participant 'ClearspringGlue:absolutize_file_urls'
      participant 'Clearspring:filter_file_urls_by_date'
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
      _if :test => '${input.lock} == true' do
        participant 'Http:fetch_file', :lock => 'clearspring-download'
      end
      _if :test => '${input.lock} == false' do
        participant 'Http:fetch_file'
      end
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
      _if :test => '${input.lock} == true' do
        participant 'Gzip:split_file', :lock => 'disk-io'
      end
      _if :test => '${input.lock} == false' do
        participant 'Gzip:split_file'
      end
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
      participant 'S3:upload_file', :lock => 's3-upload'
    end
  end
end
