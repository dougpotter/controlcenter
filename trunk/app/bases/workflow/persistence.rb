module Workflow
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
      # discovered is the initial status. we never want to change status
      # from another status to discovered. here, only create a file object
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
            :discovered_at => Time.now
          )
        end
      end
    end
    
    def already_extracted?(source_url)
      file = channel.data_provider_files.find(:first,
        :conditions => [
          'data_provider_files.url=? and status not in (?)',
          source_url,
          [DataProviderFile::DISCOVERED, DataProviderFile::BOGUS]
        ]
      )
      return !file.nil?
    end
  end
end
