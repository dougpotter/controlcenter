class MediaPurchaseMethod < ActiveRecord::Base
  acts_as_dimension
  business_index :mpm_code, :aka => "mpm"

end
