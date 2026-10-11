Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resources :invitations, only: %i[ edit update ], param: :token

  constraints OrganizationDomain do
    scope module: :tenant, as: :tenant do
      resource :dashboard, only: :show
      get "dashboard/roles", to: "dashboards#roles", as: :dashboard_roles
      root "dashboards#show"
    end
  end

  constraints PlatformDomain do
    resource :registration, only: %i[ new create ]

    namespace :admin do
      resources :organizations, only: %i[ index show ] do
        member do
          patch :change_state
        end
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "spa#index"
end
