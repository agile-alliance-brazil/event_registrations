# encoding: UTF-8
Current::Application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create' #should really be a post
  get '/auth/failure', to: 'sessions#failure'
  get '/login', to: 'sessions#new', as: :login
  delete '/logout', to: 'sessions#destroy', as: :logout

  resources :users, only: [:show, :edit, :update]

  resources :events, only: [:index, :show] do
    resources :attendances, only: [:new, :create, :index], controller: :event_attendances
    resources :registration_groups, only: [:index, :destroy]
  end

  get '/attendance_statuses/:id', to: redirect("/attendances/%{id}")
  post '/attendance_statuses/:id', to: redirect("/attendances/%{id}")
  resources :attendances, only: [:show, :destroy, :index] do
    post :enable_voting, on: :member
    get :voting_instructions, on: :member
    put :confirm, on: :member
  end
  resources :transfers, only: [:new, :create]

  resources :payment_notifications, only: :create

  root to: 'events#index'
end
