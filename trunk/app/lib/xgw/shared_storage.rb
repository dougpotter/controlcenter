require 'ruote/storage/fs_storage'
require 'xgw/globals'

module Xgw
  class SharedStorage
    attr_reader :ruote_storage
    
    def initialize
      if RuoteConfiguration.use_persistent_storage
        @ruote_storage = Ruote::FsStorage.new('work/xgw')
      else
        @ruote_storage = Ruote::HashStorage.new
      end
    end
  end
end
