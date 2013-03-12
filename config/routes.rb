# encoding: UTF-8
Current::Application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  match '/login', to: 'sessions#new', as: :login
  match '/logout', to: 'sessions#destroy', as: :logout

  resources :users, only: [:show, :edit, :update]

  resources :events, only: [:index, :show]
  
  resources :event_attendances, only: [:new, :create]
  resources :attendance_statuses, only: :show
  match '/attendance_statuses/:id', via: :post, to: 'attendance_statuses#show' #Stupid BCash callback does a post

  resources :payment_notifications, only: :create

  root :to => 'events#index'
end
