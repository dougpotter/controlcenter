spec = Gem::Specification.new do |spec|
  spec.name = 'activerecord-tableless'
  spec.summary = %q{A DEPRECATED library for implementing tableless ActiveRecord models}
  spec.description = %q{ActiveRecord Tableless provides a simple mixin for creating models that are not bound to the database. This approach is mostly useful for capitalizing on the features ActiveRecord::Validation}
  spec.authors = ["Michal Zima", "Kenneth Kalmer"]
  spec.email = "xhire@mujmalysvet.cz"
  spec.files = ["*.rb", "lib/*.rb", "Rakefile", "README", "CHANGELOG"].collect {|f| Dir.glob(f) }.flatten
  spec.version = "1.0.0"
  spec.add_dependency("activerecord", ">0", "<3.0.0")
  spec.has_rdoc = true
  spec.extra_rdoc_files = %w( README CHANGELOG )
  spec.rdoc_options.concat ['--main',  'README']
end
