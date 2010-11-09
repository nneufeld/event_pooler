EventPooler::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :controller => 'main', :action => 'index', :as => 'root'

  match '/event/event_find', :to => 'event#event_find', :as => 'event_find'
  match '/event/create', :to=> 'event#create', :as => 'event_create'
  match '/event/new', :to=> 'event#new', :as => 'event_new'
  match '/event/page/:id', :to => 'event#event_page', :as => 'event'
  match '/event/:id', :to => 'event#event_page', :as => 'event'
  match '/event/:id/attend', :to => 'event#attend', :as => 'attend_event'
  match '/event/:id/cancel_attendance', :to => 'event#cancel_attendance', :as => 'cancel_attendance'
  match '/event/:id/filter_attendees', :to => 'event#filter_attendees', :as => 'filter_attendees'
  match '/event/:id/update_sharables', :to => 'event#update_sharables', :as => 'update_sharables'
  match '/event/:id/contact_user/:user_id', :to => 'event#contact_user', :as => 'contact_user'

  match '/event/:id/create_group', :to => 'event#create_group', :as => 'create_group'
  match '/event/:id/group/:group_id/update', :to => 'event#update_group', :as => 'update_group'
  match '/event/:id/group/:group_id', :to => 'event#group', :as => 'group'
  

  match '/user/signup', :to => 'user#signup', :as => 'signup'
  match '/user/login', :to => 'user#login', :as => 'login'
  match '/user/logout', :to => 'user#logout', :as => 'logout'
	match '/user/myaccount', :to => 'user#myaccount', :as => 'myaccount'
	match '/user/delete_account', :to => 'user#delete_account', :as => 'delete_account'
  match '/user/welcome', :to => 'user#welcome', :as => 'welcome'
  match '/user/confirm/:token', :to => 'user#confirm', :as => 'confirm'
  match '/user/forgot_password', :to => 'user#forgot_password', :as => 'forgot_password'
  match '/user/reset_password/:token', :to => 'user#reset_password', :as => 'reset_password'
  
  match '/about', :to => 'content#about', :as => 'about'
  match '/about/contact', :to => 'content#contact', :as => 'contact'
  match '/learn-more', :to => 'content#learn_more', :as => 'learnmore'
  match '/legal/terms-of-use', :to => 'content#terms_of_use', :as => 'terms_of_use'
  match '/legal/privacy-policy', :to => 'content#privacy_policy', :as => 'privacy_policy'



  # See how all your routes lay out with "rake routes
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
