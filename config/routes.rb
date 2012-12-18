# encoding: UTF-8
Current::Application.routes.draw do
  root :to => 'attendees#new'

  resources :attendees, :only => [:index, :new, :create]
  match 'attendees/pre_registered' => 'attendees#pre_registered', :as => :pre_registered_attendee, :constraints => {:format => /js/}
  resources :attendee_statuses, :only => [:show]

  resources :payment_notifications, :only => [:create]
  resources :pending_attendees, :only => [:index, :update]
  resources :registered_attendees, :only => [:index, :show, :update]
  resources :registered_groups, :only => [:index, :show, :update]
  resources :registration_groups, :only => [:index, :new, :create] do
    resources :attendees, :only => [:index, :new, :create]
  end
  resources :registration_group_statuses, :only => [:show]
end
