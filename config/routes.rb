Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root "battles#index"
  
  resources :battles do
    member do
      get 'play'
      post 'resolve_turn'
      post 'perform_action'
      get 'educational_content'
      get 'replay'
      get 'statistics'
    end
  end
  
  resources :armies, only: [:index, :show]
  resources :terrains, only: [:index, :show]
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
