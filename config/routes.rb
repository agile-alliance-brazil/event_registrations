# rubocop:disable Metrics/BlockLength
Current::Application.routes.draw do
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/:provider/callback', to: 'sessions#create' # due problems without dev backdoor

  get '/auth/failure', to: 'sessions#failure'
  get '/login', to: 'sessions#new', as: :login
  delete '/logout', to: 'sessions#destroy', as: :logout

  resources :users, only: %i[show edit update index] do
    member do
      patch :toggle_organizer
      patch :toggle_admin
    end
  end

  resources :events, only: %i[index show new create destroy edit update] do
    collection do
      get :list_archived
    end

    member do
      patch :add_organizer
      delete :remove_organizer
    end

    resources :attendances, only: %i[new create edit update], controller: :event_attendances do
      collection do
        get :by_state
        get :by_city
        get :pending_attendances
        get :last_biweekly_active
        get :to_approval
        get :payment_type_report
        get :waiting_list
      end
    end
    resources :registration_groups, only: %i[index destroy show create edit update] do
      member { put :renew_invoice }
    end

    resources :payments, only: :checkout do
      member { post :checkout }
    end

    resources :registration_periods, only: %i[new create destroy edit update]
    resources :registration_quotas, only: %i[new create destroy edit update]
  end

  # rubocop:disable Style/FormatStringToken
  # Due to https://github.com/bbatsov/rubocop/issues/4425
  get '/attendance_statuses/:id', to: redirect('/attendances/%{id}')
  post '/attendance_statuses/:id', to: redirect('/attendances/%{id}')
  # rubocop:enable Style/FormatStringToken
  resources :attendances, only: %i[show index] do
    member do
      put :confirm
      put :pay_it
      put :accept_it
      delete :destroy
      put :recover_it
      patch :dequeue_it
      patch :receive_credential
    end

    collection { get :search }

    resources :transfers, only: :new
  end

  resources :payment_notifications, only: :create
  resources :transfers, only: :create

  controller :reports do
    get 'reports/:event_id/attendance_organization_size', to: 'reports#attendance_organization_size', as: :reports_attendance_organization_size
    get 'reports/:event_id/attendance_years_of_experience', to: 'reports#attendance_years_of_experience', as: :reports_attendance_years_of_experience
    get 'reports/:event_id/attendance_job_role', to: 'reports#attendance_job_role', as: :reports_attendance_job_role
    get 'reports/:event_id/burnup_registrations', to: 'reports#burnup_registrations', as: :burnup_registrations
  end

  root to: 'events#index'
end
# rubocop:enable Metrics/BlockLength
