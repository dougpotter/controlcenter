Factory.define :semaphore_allocation, :class => 'Semaphore::Allocation' do |r|
  r.expires_at Time.now + 1.hour
end
