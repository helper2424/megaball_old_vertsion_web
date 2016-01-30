MegaballWeb::Application.routes.draw do

  get "fb_auth/index"

  get "minimissions/index"
  get "news/index"
  get "bank/index"

  mount RailsAdmin::Engine => '/supper_hidden_admin', :as => 'rails_admin'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" },  :skip => [:sessions]
  as :user do
    get 'signin'                  => 'devise/sessions#new', :as => :new_user_session
    post 'signin'                 => 'devise/sessions#create', :as => :user_session
    delete 'signout'              => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  match 'stats_test' => 'game#stats_test', :via => [:post]
  
  match 'tokens/create(.:any)' => 'tokens#create', :via => [:post], :defaults => {:format => 'json'}
  #match 'game_result/:id'      => 'resource#game_result', :via => [:get], :defaults => {:format => 'json'}
  match 'map/:id'              => 'resource#map', :via => [:get], :defaults => {:format => 'json'}
  match 'ball/:id'             => 'resource#ball', :via => [:get], :defaults => {:format => 'json'}
  match 'game_event/:id'       => 'resource#game_event', :via => [:get], :defaults => {:format => 'json'}
  match 'animation/:id'        => 'resource#animation', :via => [:get], :defaults => {:format => 'json'}
  match 'users/:_id'           => 'users#show', :via => [:get] , :defaults => {:format => 'json'}
  match 'users'                => 'users#users', :via => [:get] , :defaults => {:format => 'json'}
  match 'user'                 => 'users#current', :via => [:get] , :defaults => {:format => 'json'}
  match 'user'                 => 'users#update', :via => [:post, :put, :patch] , :defaults => {:format => 'json'}
  match 'user_default'         => 'users#user_default', :via => [:get] , :defaults => {:format => 'json'}
  match 'user_items'           => 'users#user_items', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/refresh'         => 'users#refresh', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/check_first_prise' => 'users#check_first_prise', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/balance'         => 'users#balance', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/achievements'    => 'users#achievements', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/collections'     => 'users#collections', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/results'         => 'users#results', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/improve/:stat'   => 'users#improve', :via => [:post] , :defaults => {:format => 'json'}
  match 'user/messages'        => 'users#messages', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/check_weapons'   => 'users#check_weapons', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/read_message/:id'=> 'users#read_message', :via => [:post] , :defaults => {:format => 'json'}
  match 'user/ratings/:type'   => 'users#ratings', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/achievements'    => 'users#achievements', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/statistics'      => 'users#statistics', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/statistics/:id'  => 'users#statistics_by_id', :via => [:get] , :defaults => {:format => 'json'}
  match 'user/news'            => 'users#news', :via => [:get], :defaults => {:format => 'json'}
  match 'weapons/active'       => 'resource#weapons_active', :via => [:get] , :defaults => {:format => 'json'}
  match 'game_play/:id'        => 'resource#game_play', :via => [:get], :defaults => {:format => 'json'}
  match 'game_plays'           => 'resource#game_plays', :via => [:get], :defaults => {:format => 'json'}
  match 'complete_game_play/:id' => 'resource#complete_game_play', :via => [:get], :defaults => {:format => 'json'}
  match 'rooms/train'          => 'room#train', :via => [:get], :defaults => {:format => 'json'}
  match 'rooms/fast'           => 'room#fast', :via => [:get], :defaults => {:format => 'json'}
  match 'rooms/arena'           => 'room#arena', :via => [:get], :defaults => {:format => 'json'}
  match 'rooms/check_password' => 'room#check_password', :via => [:get], :defaults => {:format => 'json'}
  match 'save_log'             => 'users#save_log', :via => [:post], :defaults => {:format => 'json'}

  match 'uploader/avatar'      => 'uploader#avatar', :via => [:post], :defaults => {:format => 'json'}
  match 'uploader/mailru_avatar'      => 'uploader#mailru_avatar', :via => [:post], :defaults => {:format => 'json'}
  
  match 'super_hidden_route/user_stats/mau' => 'user_stats#mau', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/msau' => 'user_stats#msau', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/dau' => 'user_stats#dau', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/dmau' => 'user_stats#dau_mau', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/uret' => 'user_stats#users_retention', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/dconv' => 'user_stats#daily_conversion', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/mconv' => 'user_stats#monthly_conversion', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/arppu' => 'user_stats#arppu', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/sharks' => 'user_stats#sharks', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/opc' => 'user_stats#orders_per_category', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/purchase' => 'user_stats#purchase', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/faces_purchase' => 'user_stats#faces_purchase', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats' => 'user_stats#index', via: [:get], defaults: {format: 'html'}
  match 'super_hidden_route/user_stats/level_money_dependency' => 'user_stats#level_money_dependency', :via => [:get], :defaults => {:format => 'json'}
  match 'super_hidden_route/user_stats/level_money_dependency_average' => 'user_stats#level_money_dependency_average', :via => [:get], :defaults => {:format => 'json'}
  
  match 'servers/game_servers(.:any)' => 'servers#game_server_list', via: [:get], defaults: {format: 'json'}
  match 'servers/club_chat_server(.:any)' => 'servers#club_chat_server', via: [:get], defaults: {format: 'json'}

  match 'logs/game_server'  => 'logs#game_server',  via: [:get], defaults: {format: 'html'}
  match 'logs/policy'       => 'logs#policy', via: [:get], defaults: {format: 'html'}
  match 'logs/event'        => 'logs#event', via: [:get], defaults: {format: 'html'}
  match 'logs/web_server'   => 'logs#web_server', via: [:get], defaults: {format: 'html'}
  match 'logs/chat_server'  => 'logs#chat_server', via: [:get], defaults: {format: 'html'}
  match 'logs/users'        => 'logs#users', via: [:get], defaults: {format: 'html'}
  match 'mb'                => 'mb#index', via: [:get]
  match 'maps'              => 'mb#maps', via: [:get]
  match 'map/:id'           => 'mb#map', via: [:post]
  match 'mb/save'           => 'mb#save', via: [:post]

  match 'invites/check'    => 'invites#index', via: [:get]
  match 'invites/check'    => 'invites#check', via: [:post]
  match 'invites/generate' => 'invites#generate', via: [:post, :get]

  match 'store/items'             => 'store#items', via: [:get], defaults: {format: 'json'}
  match 'store/items/:_id'        => 'store#item', via: [:get], defaults: {format: 'json'}
  match 'store/items_and_weapons' => 'store#items_and_weapons', via: [:get], defaults: {format: 'json'}
  match 'store/buy'               => 'store#buy', via: [:put, :post], defaults: {format: 'json'}

  match 'club'             => 'clubs#show', :via => [:get], :defaults => {:format => 'json'}
  match 'club'             => 'clubs#update', :via => [:put, :patch, :post], :defaults => {:format => 'json'}
  match 'club/all'         => 'clubs#all', :via => [:get, :post], :defaults => {:format => 'json'}
  match 'club/join/:cid'   => 'clubs#join', :via => [:post], :defaults => {:format => 'json'}
  match 'club/accept/:uid' => 'clubs#accept', :via => [:post], :defaults => {:format => 'json'}
  match 'club/reject/:uid' => 'clubs#reject', :via => [:post], :defaults => {:format => 'json'}
  match 'club/reject_all/' => 'clubs#reject_all', :via => [:post], :defaults => {:format => 'json'}
  match 'club/kick/:uid'   => 'clubs#kick', :via => [:post], :defaults => {:format => 'json'}
  match 'club/leave'       => 'clubs#leave', :via => [:post], :defaults => {:format => 'json'}
  match 'club/requests'    => 'clubs#show_requests', :via => [:get], :defaults => {:format => 'json'}
  match 'club/role/:uid'   => 'clubs#role', :via => [:post], :defaults => {:format => 'json'}
  match 'club/rename'      => 'clubs#rename', :via => [:post], :defaults => {:format => 'json'}
  match 'club/new'         => 'clubs#new_club', :via => [:post], :defaults => {:format => 'json'}
  match 'club/update_logo' => 'clubs#update_logo', :via => [:post], :defaults => {:format => 'json'}
  match 'club/upgrade'     => 'clubs#upgrade', :via => [:post], :defaults => {:format => 'json'}
  match 'club/user'        => 'clubs#user', :via => [:get], :defaults => {:format => 'json'}

  match 'energy/update_energy' => 'energy#update_energy', :via => [:get], :defaults => {:format => 'json'}

  match 'transfer/to_club' => 'transfers#to_club', :via => [:post], :defaults => {:format => 'json'}

  match 'roulette/items' => 'roulette#items', :via => [:get], :defaults => {:format => 'json'}
  match 'roulette/chest' => 'roulette#chest', :via => [:get], :defaults => {:format => 'json'}
  match 'roulette/roll' => 'roulette#roll', :via => [:post], :defaults => {:format => 'json'}
  
  match 'fresh_man' => 'fresh_man#give_prise', :via => [:post], :defaults => {:format => 'json'}
  match 'fresh_man' => 'fresh_man#prise', :via => [:get], :defaults => {:format => 'json'}

  resource :energy_requests, only: [:create]
  match 'session_stats/create' => 'session_stats#create', :via => [:post]

  unless Rails.env.release?
    match 'dev_hook' => 'dev_hook#index', via: [:post]
  end

  namespace "payment" do
    match 'fb/callback'        => 'fb#callback', via: [:get, :post]
    match 'fb/realtime_update' => 'fb#realtime_update', via: [:get, :post]
    match 'fb/product'         => 'fb#product', via: [:get, :post]

    match 'vk/callback' => 'vk#callback', via: [:post]
    match 'ok/callback' => 'ok#callback', via: [:get]
    match 'mailru/callback' => 'mailru#callback', via: [:get]
  end

  match 'test' => 'test#index', via: [:get]

  #resources :main, :only => :index

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
  root :to => 'game#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
