# frozen_string_literal: true

RSpec.describe DeviseCustom::OmniauthCallbacksController, type: :controller do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  context 'GET #facebook' do
    let!(:user_hash) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123545', info: { name: 'foo bar', email: 'foo@bar.com.br' }) }

    before do
      OmniAuth.config.test_mode = true
      request.env['devise.mapping'] = Devise.mappings[:user]
      env = { 'omniauth.auth' => user_hash }
      request.env['omniauth.auth'] = env['omniauth.auth']
    end

    context 'when the user does not exist' do
      it 'redirects the user to complete the registration' do
        User.expects(:from_omniauth).once.returns User.new
        get :facebook
        expect(response).to redirect_to new_user_registration_path
        expect(controller.user_signed_in?).to be false
      end
    end

    context 'when the user exists' do
      context 'and it was the first login' do
        let!(:user) { FactoryBot.create :user, sign_in_count: 0 }

        it 'redirects the user to complete the registration' do
          User.expects(:from_omniauth).once.returns user
          get :facebook
          expect(response).to redirect_to edit_default_password_user_path(user)
          expect(controller.user_signed_in?).to be false
        end
      end
      context 'and it was not the first login' do
        let!(:user) { FactoryBot.create :user, sign_in_count: 1 }

        it 'redirects the user to complete the registration' do
          User.expects(:from_omniauth).once.returns user
          get :facebook
          expect(response).to redirect_to root_path
          expect(controller.user_signed_in?).to be true
        end
      end
    end
  end

  context 'GET #github' do
    context 'all infos present' do
      let!(:user_hash) { OmniAuth::AuthHash.new(provider: 'github', uid: '123545', info: { name: 'foo bar', email: 'foo@bar.com.br' }) }

      before do
        OmniAuth.config.test_mode = true
        request.env['devise.mapping'] = Devise.mappings[:user]
        env = { 'omniauth.auth' => user_hash }
        request.env['omniauth.auth'] = env['omniauth.auth']
      end

      context 'when the user does not exist' do
        it 'redirects the user to complete the registration' do
          User.expects(:from_omniauth).once.returns User.new
          get :github
          expect(response).to redirect_to new_user_registration_path
          expect(controller.user_signed_in?).to be false
        end
      end

      context 'when the user exists' do
        context 'and it was the first login' do
          let!(:user) { FactoryBot.create :user, sign_in_count: 0 }

          it 'redirects the user to complete the registration' do
            User.expects(:from_omniauth).once.returns user
            get :github
            expect(response).to redirect_to edit_default_password_user_path(user)
            expect(controller.user_signed_in?).to be false
          end
        end
        context 'and it was not the first login' do
          let!(:user) { FactoryBot.create :user, sign_in_count: 1 }

          it 'redirects the user to complete the registration' do
            User.expects(:from_omniauth).once.returns user
            get :github
            expect(response).to redirect_to root_path
            expect(controller.user_signed_in?).to be true
          end
        end
      end
    end

    context 'no email present' do
      let!(:user_hash) { OmniAuth::AuthHash.new(provider: 'github', uid: '123545', info: { name: 'foo bar', email: nil }) }

      before do
        OmniAuth.config.test_mode = true
        request.env['devise.mapping'] = Devise.mappings[:user]
        env = { 'omniauth.auth' => user_hash }
        request.env['omniauth.auth'] = env['omniauth.auth']
      end

      context 'when the does not have the email in the provider' do
        it 'redirects back to the login with an alert' do
          get :github
          expect(response).to redirect_to new_user_session_path
          expect(flash[:error]).to eq I18n.t('devise.omniauth_callbacks.missing_email')
        end
      end
    end
  end

  context 'GET #twitter' do
    let!(:user_hash) { OmniAuth::AuthHash.new(provider: 'twitter', uid: '123545', info: { name: 'foo bar', email: 'foo@bar.com.br' }) }

    context 'all infos present' do
      before do
        OmniAuth.config.test_mode = true
        request.env['devise.mapping'] = Devise.mappings[:user]
        env = { 'omniauth.auth' => user_hash }
        request.env['omniauth.auth'] = env['omniauth.auth']
      end

      context 'when the user does not exist' do
        it 'redirects the user to complete the registration' do
          User.expects(:from_omniauth).once.returns User.new
          get :twitter
          expect(response).to redirect_to new_user_registration_path
          expect(controller.user_signed_in?).to be false
        end
      end

      context 'when the user exists' do
        context 'and it was the first login' do
          let!(:user) { FactoryBot.create :user, sign_in_count: 0 }

          it 'redirects the user to complete the registration' do
            User.expects(:from_omniauth).once.returns user
            get :twitter
            expect(response).to redirect_to edit_default_password_user_path(user)
            expect(controller.user_signed_in?).to be false
          end
        end
        context 'and it was not the first login' do
          let!(:user) { FactoryBot.create :user, sign_in_count: 1 }

          it 'redirects the user to complete the registration' do
            User.expects(:from_omniauth).once.returns user
            get :twitter
            expect(response).to redirect_to root_path
            expect(controller.user_signed_in?).to be true
          end
        end
      end
    end

    context 'no email present' do
      let!(:user_hash) { OmniAuth::AuthHash.new(provider: 'twitter', uid: '123545', info: { name: 'foo bar', email: nil }) }

      before do
        OmniAuth.config.test_mode = true
        request.env['devise.mapping'] = Devise.mappings[:user]
        env = { 'omniauth.auth' => user_hash }
        request.env['omniauth.auth'] = env['omniauth.auth']
      end

      context 'when the does not have the email in the provider' do
        it 'redirects back to the login with an alert' do
          get :twitter
          expect(response).to redirect_to new_user_session_path
          expect(flash[:error]).to eq I18n.t('devise.omniauth_callbacks.missing_email')
        end
      end
    end
  end
end
