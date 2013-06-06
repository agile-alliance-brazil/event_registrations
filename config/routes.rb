# encoding: UTF-8
Current::Application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  match '/login', to: 'sessions#new', as: :login
  match '/logout', to: 'sessions#destroy', as: :logout

  resources :users, only: [:show, :edit, :update]

  resources :events, only: [:index, :show] do
    resources :attendances, only: [:new, :create, :index, :destroy] do
      post :enable_voting, on: :member
      get :voting_instructions, on: :member
    end
  end

  resources :attendance_statuses, only: :show
  match '/attendance_statuses/:id', via: :post, to: 'attendance_statuses#callback' #Stupid BCash callback does a post

  resources :payment_notifications, only: :create

  root :to => 'events#index'
end
