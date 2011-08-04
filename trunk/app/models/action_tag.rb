class ActionTag < ActiveRecord::Base
  belongs_to :partner

  validates_presence_of :name, :sid, :url, :partner_id
  validates_uniqueness_of :sid
  validates_numericality_of :sid, :greater_than => 9999, :less_than => 100000
end
