# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :authenticate_user!

  private

  def check_organizer
    not_found unless current_user.organizer_of?(@event)
  end

  def check_admin
    not_found unless current_user.admin?
  end
end
