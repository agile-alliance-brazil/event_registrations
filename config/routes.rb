# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Current::Application.routes.draw do
  devise_for :users, controllers: { registrations: 'devise_custom/registrations', omniauth_callbacks: 'devise_custom/omniauth_callbacks' }

  # To keep compatibility with old routes sent by email
  # In the future (new events) it can be removed
  get('attendances/:id', to: redirect do |params, request|
    path = "events/#{Attendance.find_by(id: params[:id])&.event_id}/attendances/#{params[:id]}"
    "http://#{request.host_with_port}/#{path}"
  end)

  resources :users, only: %i[show edit update index] do
    member do
      patch :update_to_organizer
      patch :update_to_admin
      get :edit_default_password
      patch :update_default_password
    end

    get :search_users, on: :collection
  end

  resources :events, only: %i[index show new create destroy edit update] do
    get :list_archived, on: :collection

    member do
      patch :add_organizer
      delete :remove_organizer
    end

    resources :attendances do
      member do
        patch 'change_status/:new_status', action: :change_status, as: 'change_status'
        delete :destroy
      end

      collection do
        get :pending_attendances
        get :search
        get :attendance_past_info
        get :user_info
      end
    end

    resources :transfers, only: %i[new create]

    resources :registration_groups, only: %i[new destroy show create edit update]

    resources :payments, only: :checkout do
      member { post :checkout }
    end

    resources :registration_periods, only: %i[new create destroy edit update]
    resources :registration_quotas, only: %i[new create destroy edit update]
  end

  resources :payment_notifications, only: :create

  root to: 'events#index'
end
# rubocop:enable Metrics/BlockLength
