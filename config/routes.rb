Current::Application.routes.draw do
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/:provider/callback', to: 'sessions#create' # due problems without dev backdoor

  get '/auth/failure', to: 'sessions#failure'
  get '/login', to: 'sessions#new', as: :login
  delete '/logout', to: 'sessions#destroy', as: :logout

  resources :users, only: %i(show edit update index) do
    member do
      patch :toggle_organizer
      patch :toggle_admin
    end
  end

  resources :events, only: %i(index show new create destroy edit update) do
    collection do
      get :list_archived
    end

    member do
      patch :add_organizer
      delete :remove_organizer
    end

    resources :attendances, only: %i(new create edit update), controller: :event_attendances do
      collection do
        get :by_state
        get :by_city
        get :pending_attendances
        get :last_biweekly_active
        get :to_approval
        get :payment_type_report
      end
    end
    resources :registration_groups, only: %i(index destroy show create) do
      member { put :renew_invoice }
    end

    resources :payments, only: :checkout do
      member { post :checkout }
    end

    resources :registration_periods, only: [:new, :create, :destroy]
    resources :registration_quotas, only: [:new, :create, :destroy]
  end

  get '/attendance_statuses/:id', to: redirect('/attendances/%{id}')
  post '/attendance_statuses/:id', to: redirect('/attendances/%{id}')
  resources :attendances, only: %i(show index) do
    member do
      put :confirm
      put :pay_it
      put :accept_it
      delete :destroy
      put :recover_it
    end

    collection { get :search }

    resources :transfers, only: :new
  end

  resources :payment_notifications, only: :create
  resources :transfers, only: :create

  root to: 'events#index'
end
