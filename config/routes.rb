Rails.application.routes.draw do
  devise_for :users,
    path: "api/v1",
    defaults: { format: :json },
    path_names: { sign_in: "login", sign_out: "logout", registration: "signup" },
    controllers: {
      sessions: "api/v1/sessions",
      registrations: "api/v1/registrations"
    }

  namespace :api do
    namespace :v1 do
      get "meta", to: "meta#index"                # enum options
      resources :creator_requests, only: %i[index create]
      namespace :admin do
        resources :creator_requests, only: %i[index update]
      end
      resources :creators, only: %i[index show] do
        member do
          post :subscribe
          delete :subscribe, action: :unsubscribe
        end
      end
      resources :subscriptions, only: %i[index]
      resources :dashboards, only: %i[index show create update destroy] do
        member do
          get :export
          get :stats
        end
        resources :matches, only: %i[index show create update destroy]
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
