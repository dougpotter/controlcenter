module ActionView::Helpers
  module AssetTagHelper
    remove_const(:STYLESHEETS_DIR)
    STYLESHEETS_DIR = "#{ASSETS_DIR}/compiled/stylesheets"
    
    private
    
    def compute_public_path_with_compiled_stylesheets(source, dir, ext=nil, include_host=true)
      if dir == 'stylesheets'
        dir = 'compiled/stylesheets'
      end
      compute_public_path_without_compiled_stylesheets(source, dir, ext, include_host)
    end
    alias_method_chain :compute_public_path, :compiled_stylesheets
  end
end
