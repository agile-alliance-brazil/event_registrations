# encoding: UTF-8
Current::Application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  match '/login', to: 'sessions#new', as: :login
  match '/logout', to: 'sessions#destroy', as: :logout

  resources :users, only: [:show, :edit, :update]

  resources :events, only: [:index, :show] do
    resources :attendances, only: [:new, :create, :index], controller: :event_attendances
  end

  match '/attendance_statuses/:id', to: redirect("/attendances/%{id}")
  match '/attendance_statuses/:id', via: :post, to: redirect("/attendances/%{id}")
  resources :attendances, only: [:show, :destroy] do
    post :enable_voting, on: :member
    get :voting_instructions, on: :member
    put :confirm, on: :member
  end
  resources :transfers, only: [:new, :create]

  resources :payment_notifications, only: :create

  root :to => 'events#index'
end
