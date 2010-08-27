# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{seed-fu}
  s.version = "1.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh"]
  s.date = %q{2010-01-20}
  s.description = %q{Seed Fu is an attempt to once and for all solve the problem of inserting and maintaining seed data in a database. It uses a variety of techniques gathered from various places around the web and combines them to create what is hopefully the most robust seed data system around.}
  s.email = %q{michael@intridea.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/seed-fu.rb",
     "lib/seed-fu/writer.rb",
     "lib/seed-fu/writer/abstract.rb",
     "lib/seed-fu/writer/seed.rb",
     "lib/seed-fu/writer/seed_many.rb",
     "rails/init.rb",
     "spec/schema.rb",
     "spec/seed_fu_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/mblegih/seed-fu}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Allows easier database seeding of tables in Rails.}
  s.test_files = [
    "spec/schema.rb",
     "spec/seed_fu_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 2.1"])
    else
      s.add_dependency(%q<rails>, [">= 2.1"])
    end
  else
    s.add_dependency(%q<rails>, [">= 2.1"])
  end
end

