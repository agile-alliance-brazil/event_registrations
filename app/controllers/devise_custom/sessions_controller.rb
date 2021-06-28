# frozen_string_literal: true

module DeviseCustom
  class SessionsController < Devise::SessionsController
    def create
      self.resource = warden.authenticate!(auth_options)

      return redirect_to edit_default_password_user_path(resource) if resource.sign_in_count.zero?

      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end
end
