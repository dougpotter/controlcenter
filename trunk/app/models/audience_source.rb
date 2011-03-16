class AudienceSource < ActiveRecord::Base
  has_many :audience_manifests
  has_many :audiences, :through => :audience_manifests
end
