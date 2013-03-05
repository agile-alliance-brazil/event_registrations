# encoding: UTF-8
Current::Application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  match '/auth/backdoor', to: 'sessions#backdoor' if Rails.env == 'development'
  match '/login', to: 'sessions#new', as: :login
  match '/logout', to: 'sessions#destroy', as: :logout

  resources :users, only: [:show, :edit, :update]

  resources :events, only: [:index, :show]
  
  resources :event_attendances, only: [:new, :create]
  resources :attendance_statuses, only: [:show, :update]

  resources :payment_notifications, only: :create

  root :to => 'events#index'
end
