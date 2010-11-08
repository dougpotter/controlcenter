ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  
  map.metrics_report '/home/metrics/report', :controller => 'landing_pages', :action => 'report'
  map.metrics_home "/home/metrics", :controller => "landing_pages", :action => "metrics" 
  map.update_form "/home/metrics/update_form", :controller => "landing_pages", :action => "update_form"
  
  # Facts are known on the outside as "metrics"
  map.resources :facts, :as => "metrics"
  # Also allow for accessing Facts#update without :id, per API spec
  map.connect "/metrics", :controller => "facts", :action => "update", 
    :conditions => { :method => :put }
  
  map.resources :campaigns, :controller => 'campaign_management', :as => 'campaign_management'
  
  map.extraction_index '/extraction',
    :controller => 'extraction', :action => 'index'
  map.extraction_overview '/extraction/overview/:year/:month',
    :controller => 'extraction', :action => 'overview'
  map.extraction_details '/extraction/details/:date',
    :controller => 'extraction', :action => 'details'

  map.resources :audiences
  map.resources :partners
  map.resources :ad_inventory_sources
  map.resources :creatives

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "landing_pages",
           :action => "metrics"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
