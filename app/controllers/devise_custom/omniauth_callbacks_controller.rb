# frozen_string_literal: true

module DeviseCustom
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def github
      process_omniauth('devise.github_data', 'github')
    end

    def facebook
      process_omniauth('devise.faceook_data', 'facebook')
    end

    def twitter
      process_omniauth('devise.twitter_data', 'twitter')
    end

    private

    def process_omniauth(omniauth_session, omniauth_provider)
      if request.env['omniauth.auth']['info']['email'].blank?
        flash[:error] = I18n.t('devise.omniauth_callbacks.missing_email')
        return redirect_to new_user_session_path
      end

      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        complete_login(omniauth_provider)
      else
        session[omniauth_session] = request.env['omniauth.auth'].except('extra')
        redirect_to new_user_registration_url
      end
    end

    def complete_login(omniauth_provider)
      return redirect_to edit_default_password_user_path(@user) if @user.sign_in_count.zero?

      sign_in_and_redirect(@user, event: :authentication)
      set_flash_message(:notice, :success, kind: omniauth_provider) if is_navigational_format?
    end
  end
end
