# Template handlers are broken
#require 'shpaml/compiler'
#require 'shpaml/template_handlers/shpaml_erb'

#ActionView::Template.register_template_handler(:erbs, Shpaml::TemplateHandlers::ShpamlErb)

# In production use rake shpaml:compile to compile everything during deployment.
# In testing use rake shpaml:compile before running tests.
if Rails.env == 'development'
  require 'shpaml/development_middleware'
end
