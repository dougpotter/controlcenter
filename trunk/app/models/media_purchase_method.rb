class MediaPurchaseMethod < ActiveRecord::Base
  
  def get_handle
    :mpm_code
  end

  def self.handle_to_id(mpm_code)
    find_by_mpm_code(mpm_code).id
  end

  def self.id_to_handle(id)
    find(id).mpm_code
  end
end