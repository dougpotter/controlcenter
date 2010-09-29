# Shpaml template handlers.
#
# There are two ways of using shpaml:
#
# 1. In production, all shpaml templates are compiled to erb/builder/etc.
# templates during deployment, after which shpaml is completely out of the
# picture. Templates are then rendered by rails as usual.
#
# 2. In development, shpaml templates are compiled each time a view is rendered.
# Ideally shpaml template handler can convert shpaml and then get actionview
# to figure out how to compile the resulting text; barring that shpaml template
# handler needs versions for every other template type rails supports (erb, builder, etc.)
module Shpaml
  module TemplateHandlers
    class ShpamlErb < ActionView::TemplateHandler
      def initialize(view)
        @view = view
      end
      
      def render(template, local_assigns)
        erb_text = Shpaml::Compiler.new.compile(:source => template.source)
        debugger
        #erb_template = InlineTemplate.new(erb_text)
        #ActionView::TemplateHandlers::ERB.call(template).render(template, local_assigns)
      end
    end
  end
end
