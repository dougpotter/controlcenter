Rails.configuration.after_initialize do
  DelayedLoad.configure :sass do
    ::Sass::Plugin.options[:template_location] = Rails.root.join('public/stylesheets').to_s
    ::Sass::Plugin.options[:css_location] = Rails.root.join('public/compiled/stylesheets').to_s
  end
end
