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
  
  map.extraction_index '/extraction',
    :controller => 'extraction', :action => 'index'
  map.extraction_overview '/extraction/overview/:year/:month',
    :controller => 'extraction', :action => 'overview'
  map.extraction_details '/extraction/details/:date',
    :controller => 'extraction', :action => 'details'
  
  map.appnexus_sync_index '/appnexus/sync',
    :controller => 'appnexus', :action => 'index', :conditions => {:method => :get}
  map.appnexus_sync_list_impl '/appnexus/sync/:year/:month',
    :controller => 'appnexus', :action => 'list',
    :conditions => {:method => :get},
    :year => /\d{4}/, :month => /\d\d/
  map.new_appnexus_sync '/appnexus/sync/new',
    :controller => 'appnexus', :action => 'new'
  map.create_appnexus_sync '/appnexus/sync',
    :controller => 'appnexus', :action => 'create', :conditions => {:method => :post}
  map.appnexus_sync '/appnexus/sync/:id',
    :controller => 'appnexus', :action => 'show'
  map.appnexus_sync_log '/appnexus/log',
    :controller => 'appnexus', :action => 'show_log'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "extraction",
           :action => "index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
