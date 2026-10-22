Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  post "auth/login", to: "auth#login"

  namespace :admin do
    resources :brands, only: %i[index show create update] do
      patch :state, on: :member
      resources :products, only: %i[index create]
    end

    resources :products, only: %i[show update destroy] do
      patch :state, on: :member
    end

    resources :clients, only: %i[index show create update] do
      patch :state, on: :member
      resource :products, only: %i[show update], controller: "client_products"
    end
  end

  namespace :client do
    resources :products, only: %i[index show]
    resources :cards, only: %i[create]
  end
end
