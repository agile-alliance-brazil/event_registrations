# encoding: UTF-8
Current::Application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  match '/login', to: 'sessions#new', as: :login
  match '/logout', to: 'sessions#destroy', as: :logout

  resources :users, except: [:index, :destroy]
  resources :event_attendances, only: [:new, :create]
  resources :attendance_statuses, only: :show
  resources :authentications, only: :destroy

  resources :payment_notifications, only: :create

  root :to => 'users#show'
end
