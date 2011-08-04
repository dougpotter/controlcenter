class ActionTag < ActiveRecord::Base
  belongs_to :partner

  validates_presence_of :name, :sid, :url, :partner_id
end
