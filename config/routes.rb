ActionController::Routing::Routes.draw do |map|
  # Custom routes
  map.with_options(:controller => 'account') do |login|
    login.account_login  '/login',         :action => 'login'
    login.account_logout '/logout',        :action => 'logout'
    login.access_denied  '/access_denied', :action => 'access_denied'
  end
  

  # Standard routes
  map.resources :account,         :collection => { :activate => :get, :forgot_password => :any, :reset_password => :any }
  map.resources :companies,       :only => [:edit, :update, :destroy]
  map.resources :filters,         :only => [:index, :create]
  map.resources :invites
  map.resources :users

  # Default routes
  map.connect '/:action', :controller => 'html'
end
