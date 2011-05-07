Abstract::Application.routes.draw do
  devise_for :users

  resources :users do
    collection do
      get 'view'
    end
  end
  resources :roles do
    collection do
      get 'view'
    end
  end
  resources :entities do
    collection do
      get 'view'
    end
  end
  resources :resources do
    member do
      get 'edit_asset'
      get 'edit_money'
      put 'update_asset'
      put 'update_money'
    end
    collection do
      get 'new_asset'
      get 'new_money'
      post 'create_asset'
      post 'create_money'
      get 'view'
    end
  end
  resources :deals do
    collection do
      get 'view'
    end
  end
  resources :facts
  resources :charts
  resources :quotes do
    collection do
      get 'view'
    end
  end
  resources :balances do
    collection do
      get 'load'
    end
  end
  resources :general_ledgers do
    collection do
      get 'view'
    end
  end
  resources :transcripts do
    collection do
      get 'load'
    end
  end
  resources :rules
  resources :waybills do
    collection do
      get 'view'
    end
  end
  resources :storehouses do
    collection do
      get 'view'
      get 'releases'
      get 'list'
    end
  end
  get "home/index"

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
  # root :to => "welcome#index"
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  match ':controller/releases/:action', :to => 'storehouses#create'
  match ':controller/releases/:action', :to => 'storehouses#new'
  match ':controller/releases/:action', :to => 'storehouses#list'
end
