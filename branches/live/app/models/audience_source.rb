class AudienceSource < ActiveRecord::Base
  has_many :audience_manifests, :dependent => :destroy
  has_many :audiences, :through => :audience_manifests

  def <=>(that)
    self.class.to_s <=> that.class.to_s
  end

  # necessary when using accepts_nested_attributes_for and STI
  # http://stackoverflow.com/questions/2553931/can-nested-attributes-be-used-in-combination-with-inheritance
  private
  def attributes_protected_by_default
    super - [self.class.inheritance_column]
  end
end
