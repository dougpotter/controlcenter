module Workflow
  # Some of the methods are used only for verification, but include everything
  # here since I like this layout more.
  module Persistence
    def create_data_provider_file(file_url)
      # Locked and lock-free runs should not be combined, since lock-free run may
      # overwrite data of the locked run and leave it in an inconsistent state
      # and the locked run would report success.
      #
      # Due to verification and also rerunning extraction however we must allow
      # updating status on existing files.
      
      DataProviderFile.transaction do
        file = channel.data_provider_files.find_by_url(file_url)
        if file
          if block_given?
            yield file
            file.save!
          end
        else
          begin
            file = DataProviderFile.new(
              :url => file_url,
              :data_provider_channel => channel
            )
            if block_given?
              yield file
            end
            file.save!
          rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid
            # see if someone else created the file concurrently
            file = channel.data_provider_files.find_by_url(file_url)
            unless file
              raise
            end
            # XXX what are the actual use cases that would generate conflicts?
            # what should we do in these cases?
            if block_given?
              yield file
            end
            file.save!
          end
        end
      end
    end
    
    def note_data_provider_file_discovered(file_url)
      # Determine label date and hour from file name.
      # Currently we only do this for discovered files because the only
      # consumer of that information, presently, is extraction of files
      # that are uploaded/made available late compared to their label time.
      begin
        date, hour = determine_label_date_hour_from_data_provider_file(file_url)
      rescue DataProviderFileBogus
        # We were unable to determine date/hour from the file name.
        # Record the file anyway so that it can be looked at by a human/
        # when reviewing extraction status.
        date = hour = nil
      end
      
      # Discovered is the initial status. We never want to change status
      # from another status to discovered. Here, only create a file object
      # if it does not already exist.
      DataProviderFile.transaction do
        file = channel.data_provider_files.find_by_url(file_url)
        if file
          if file.discovered_at.nil?
            file.discovered_at = Time.now
            file.save!
          end
        else
          file = DataProviderFile.create!(
            :url => file_url,
            :data_provider_channel => channel,
            :status => DataProviderFile::DISCOVERED,
            :label_date => date,
            :label_hour => hour,
            :discovered_at => Time.now
          )
        end
      end
    end
    
    def data_provider_file_extracted?(source_url)
      file = channel.data_provider_files.first(
        :conditions => [
          'data_provider_files.url=? and status in (?)',
          source_url,
          [DataProviderFile::EXTRACTED, DataProviderFile::VERIFIED]
        ]
      )
      return !file.nil?
    end
    
    def data_provider_file_verified?(source_url)
      file = channel.data_provider_files.first(
        :conditions => [
          'data_provider_files.url=? and status=?',
          source_url, DataProviderFile::VERIFIED
        ]
      )
      return !file.nil?
    end
    
    def mark_data_provider_file_bogus(file_url)
      # we only want to mark previously verified files as bogus; if a file
      # was not verified, we're not going to change its status.
      # if no record exists for a file, we are not going to create one here
      # either
      DataProviderFile.transaction do
        # we don't want to mark bogus files that are being extracted,
        # or files that we have not yet attempted to extract.
        # we want to mark bogus files which have been extracted, this is easy.
        # we also want to mark bogus files that have been verified, because
        # we have different verification levels and stricter levels may
        # reject files that less strict levels claimed were correctly extracted.
        file = channel.data_provider_files.first(
          :conditions => ['url = ? and status in (?)',
          file_url,
          [DataProviderFile::EXTRACTED, DataProviderFile::VERIFIED]]
        )
        if file
          file.status = DataProviderFile::BOGUS
          file.verified_at = nil
          file.save!
        end
      end
    end
  end
end
