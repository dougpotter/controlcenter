class AudienceSource < ActiveRecord::Base
  has_many :audience_manifests, :dependent => :destroy
  has_many :audiences, :through => :audience_manifests
end
