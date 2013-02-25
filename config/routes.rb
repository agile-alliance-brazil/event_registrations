# encoding: UTF-8
Current::Application.routes.draw do
  root :to => 'sessions#new'

  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  match '/login', to: 'sessions#new', as: :login
  match '/logout', to: 'sessions#destroy', as: :logout

  resources :users, except: [:index, :destroy]
  resources :event_attendances, only: [:new, :create] do
    match '/status', to: 'event_attendances#status', as: :attendance_status
  end
  resources :authentications, only: :destroy

  resources :payment_notifications, only: :create
end
