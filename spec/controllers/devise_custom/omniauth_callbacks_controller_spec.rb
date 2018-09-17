# frozen_string_literal: true

RSpec.describe DeviseCustom::OmniauthCallbacksController, type: :controller do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  context 'GET #facebook' do
    before do
      OmniAuth.config.test_mode = true
      request.env['devise.mapping'] = Devise.mappings[:user]
      env = { 'omniauth.auth' => { provider: 'facebook', uid: '1234', extra: { user_hash: { email: 'foo@bar.com' } } } }
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
    context 'GET #facebook' do
      before do
        OmniAuth.config.test_mode = true
        request.env['devise.mapping'] = Devise.mappings[:user]
        env = { 'omniauth.auth' => { provider: 'facebook', uid: '1234', extra: { user_hash: { email: 'foo@bar.com' } } } }
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
  end
  context 'GET #github' do
    before do
      OmniAuth.config.test_mode = true
      request.env['devise.mapping'] = Devise.mappings[:user]
      env = { 'omniauth.auth' => { provider: 'github', uid: '1234', extra: { user_hash: { email: 'foo@bar.com' } } } }
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

  context 'GET #twitter' do
    before do
      OmniAuth.config.test_mode = true
      request.env['devise.mapping'] = Devise.mappings[:user]
      env = { 'omniauth.auth' => { provider: 'twitter', uid: '1234', extra: { user_hash: { email: 'foo@bar.com' } } } }
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

  context 'GET #linkedin' do
    before do
      OmniAuth.config.test_mode = true
      request.env['devise.mapping'] = Devise.mappings[:user]
      env = { 'omniauth.auth' => { provider: 'linkedin', uid: '1234', extra: { user_hash: { email: 'foo@bar.com' } } } }
      request.env['omniauth.auth'] = env['omniauth.auth']
    end

    context 'when the user does not exist' do
      it 'redirects the user to complete the registration' do
        User.expects(:from_omniauth).once.returns User.new
        get :linkedin
        expect(response).to redirect_to new_user_registration_path
        expect(controller.user_signed_in?).to be false
      end
    end

    context 'when the user exists' do
      context 'and it was the first login' do
        let!(:user) { FactoryBot.create :user, sign_in_count: 0 }

        it 'redirects the user to complete the registration' do
          User.expects(:from_omniauth).once.returns user
          get :linkedin
          expect(response).to redirect_to edit_default_password_user_path(user)
          expect(controller.user_signed_in?).to be false
        end
      end
      context 'and it was not the first login' do
        let!(:user) { FactoryBot.create :user, sign_in_count: 1 }

        it 'redirects the user to complete the registration' do
          User.expects(:from_omniauth).once.returns user
          get :linkedin
          expect(response).to redirect_to root_path
          expect(controller.user_signed_in?).to be true
        end
      end
    end
  end
end
