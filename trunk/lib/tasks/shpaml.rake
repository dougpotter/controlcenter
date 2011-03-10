namespace :shpaml do

  namespace :compile do

    desc "Compile a specific shpaml template passed in TEMPLATE=\nNOTE: performs" +
      " a simple substring search of complete paths to all view files for" +
      " whatever follows TEMPLATE="
    task :template => :environment do

      file_to_compile = ENV["TEMPLATE"]
      discoverer = Shpaml::Discoverer.new(File.join(Rails.root, 'app', 'views'))
      compiler = Shpaml::Compiler.new

      found = false
      discoverer.find_shpaml_templates do |source_path|
        if source_path.match(file_to_compile)
          found = true
          dest_path = source_path.sub(/\.shpaml$/, '') 
          if source_path == dest_path
            raise ArgumentError, "Cannot compile a template to itself"
          end 

          compiler.compile_file(source_path, dest_path)
        end
      end

      if !found
        raise ArgumentError, "Cannot find file #{file_to_compile}"
      end
    end
  end
end
