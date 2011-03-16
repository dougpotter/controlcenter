class AudienceManifest < ActiveRecord::Base
  belongs_to :audience_source
  belongs_to :audience

  validates_presence_of :audience_id, 
    :audience_source_id, 
    :audience_iteration_number

  before_validation :populate_iteration_number

  def populate_iteration_number
    if am = AudienceManifest.find(
      :last, 
      :conditions => {:audience_id => self.audience_id}
    )
      self.audience_iteration_number = am.audience_iteration_number + 1
    else 
      self.audience_iteration_number = 0
    end
  end


end
