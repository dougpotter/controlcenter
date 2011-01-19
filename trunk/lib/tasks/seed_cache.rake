namespace :dim_cache do

  desc "seed cache with dimension relationships"
  task :seed_relationships => :environment do
    DimensionCache.reset
    DimensionCache.seed_relationships(:verbose => true)
  end

  desc "reset cache"
  task :reset => :environment do
    DimensionCache.reset
  end
end
