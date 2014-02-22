Pagpos::Application.routes.draw do
  get 'trackings' => 'trackings#new', as: 'new_tracking'
  get 'tracking/:code/:token' => 'trackings#show', as: 'tracking'
  post 'trackings' => 'trackings#create'
  delete 'tracking/:code/:token' => 'trackings#destroy'

  get 'welcome' => "welcome#index"

  get 'pagpos' => "pagpos#new"
  post 'pagpos' => "pagpos#create"
  get 'pagpos/:code' => "pagpos#show" #, as: "pagpos_result"

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  # get 'users/auth/facebook' => 'omniauth_callbacks#passthru'
  # get 'users/auth/google' => 'omniauth_callbacks#passthru'
  # get 'users/auth/twitter' => 'omniauth_callbacks#passthru'

  devise_scope :user do
    # root to: 'devise/sessions#new'
    root to: 'welcome#index'
    get 'users' => "users#index"
    put 'users/:id' => 'users#update', as: 'user_update'
    get 'user_profile' => 'users#edit'
    get 'users/auth/:provider' => 'omniauth_callbacks#passthru'

    get 'send_fbchat' => 'api/v1/pagpos#fbchat'

    namespace :store do
      root to: 'dashboards#index'
      get 'login' => 'stores#index', as: 'login'
      post 'login' => 'stores#login'
      get 'register' => 'stores#new'
      post 'register' => 'stores#create'
    end

  end

  namespace :api do
    namespace :v1  do
      devise_for :users
      root to: 'welcome#index'

      # Trackings always send :code and :token
      get 'trackings/:code/:token' => 'trackings#show', as: 'trackings'
      post 'trackings' => 'trackings#create'
      delete 'trackings' => 'tracking#destroy'

      get 'force_get_data' => 'pagpos#force_get_data'
      get 'show' => 'pagpos#show'
      # get 'auth/:provider' => 'omniauth_callbacks#passthru'
      # get 'auth/facebook' => 'omniauth_callbacks#passthru'
      # get 'auth/google' => 'omniauth_callbacks#passthru'
      # get 'auth/twitter' => 'omniauth_callbacks#passthru'
    end
  end

  mount Resque::Server, :at => "/resque"
  # authenticate :user do
    # mount Resque::Server, :at => "/resque"
  # end


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
