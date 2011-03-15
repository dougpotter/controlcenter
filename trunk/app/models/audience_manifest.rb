class AudienceManifest < ActiveRecord::Base
  validates_presence_of :audience_id, 
    :audience_source_id, 
    :audience_iteration_number
end
