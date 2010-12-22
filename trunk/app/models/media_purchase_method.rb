# == Schema Information
# Schema version: 20101220202022
#
# Table name: media_purchase_methods
#
#  id       :integer(4)      not null, primary key
#  mpm_code :string(255)
#

class MediaPurchaseMethod < ActiveRecord::Base
  acts_as_dimension
  business_index :mpm_code, :aka => "mpm"

end
