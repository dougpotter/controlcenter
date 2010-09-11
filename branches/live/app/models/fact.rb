class Fact
  include FactBehaviors
  acts_as_fact
end

# Force load fact models
# TODO: Write rake task to preload necessary dictionaries
%w{
  impression_count click_count
}.each do |rbfile|
  require rbfile
end
