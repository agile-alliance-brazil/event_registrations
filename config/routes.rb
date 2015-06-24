# encoding: UTF-8
Current::Application.routes.draw do
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/:provider/callback', to: 'sessions#create' # due problems without dev backdoor

  get '/auth/failure', to: 'sessions#failure'
  get '/login', to: 'sessions#new', as: :login
  delete '/logout', to: 'sessions#destroy', as: :logout

  resources :users, only: [:show, :edit, :update]

  resources :events, only: [:index, :show] do
    resources :attendances, only: [:new, :create, :edit, :update], controller: :event_attendances
    resources :registration_groups, only: [:index, :destroy, :show, :create] do
      member do
        put :renew_invoice
      end
    end

    resources :payments, only: [:checkout] do
      member do
        post :checkout
      end
    end
  end

  get '/attendance_statuses/:id', to: redirect('/attendances/%{id}')
  post '/attendance_statuses/:id', to: redirect('/attendances/%{id}')
  resources :attendances, only: [:show, :index] do
    member do
      post :enable_voting
      get :voting_instructions
      put :confirm
      put :pay_it
      put :accept_it
      delete :destroy
    end
  end
  resources :transfers, only: [:new, :create]

  resources :payment_notifications, only: :create

  root to: 'events#index'
end
