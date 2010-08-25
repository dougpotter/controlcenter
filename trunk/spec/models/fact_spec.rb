require 'spec_helper'
require 'yaml'

describe Fact do
  fact_def_dir = File.join(RAILS_ROOT, 'app', 'models', 'fact_definitions')
  @facts = []
  Dir.foreach(fact_def_dir) do |fact_def_file|
    if fact_def_file.match(/\.yml$/)
      @facts << fact_def_file.match(/(.+)\.yml/)[1]
    end
  end
  before(:each) do

  end

  for fact in @facts
    fact_def_file = File.join(fact_def_dir, fact + ".yml")
    @@definition = YAML::load_file(fact_def_file)
    @@required_dimensions  = []
    @@required_dimensions += @@definition[:required_dimensions][:objects]
    @@required_dimensions += @@definition[:required_dimensions][:non_objects]
    # uncomment when we've expanded API to accomodate parent classes
    #@@required_dimensions += @@definition[:required_dimensions][:parent]


    for dimension in @@required_dimensions
      it "should fail to create a(n) #{fact} missing required dimension #{dimension}", {:fact => fact, :dimension => dimension} do
        lambda {
          Factory.create(options[:fact].to_sym, options[:dimension].to_sym => nil)
        }.should raise_error
      end
    end

    it "should succeed in creating a #{fact} missing all optional dimensions", {:optional_dimensions => @@definition[:optional_dimensions]} do 
      optionals_set_to_null = Hash[*options[:optional_dimensions].collect { |v| [v,nil] }.flatten]
      Factory.create(options[:fact].to_sym, optionals_set_to_null)
    end

    it "should fail to create a #{fact} with ANY conflicting dimensions" do
       
    end
  end
end
