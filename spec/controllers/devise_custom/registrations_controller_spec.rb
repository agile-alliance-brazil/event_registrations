# frozen_string_literal: true

RSpec.describe DeviseCustom::RegistrationsController, type: :controller do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  context 'unauthenticated' do
    describe 'POST #create' do
      context 'with valid parameters' do
        it 'creates the user' do
          post :create, params: { user: { first_name: 'foo', last_name: 'bar', email: 'foo@bar.com.br', password: 'abc123', password_confirmation: 'abc123' } }
          expect(response).to redirect_to root_path
          expect(User.count).to eq 1
          expect(User.last.first_name).to eq 'foo'
          expect(User.last.last_name).to eq 'bar'
          expect(User.last.email).to eq 'foo@bar.com.br'
        end
      end

      context 'with invalid parameters' do
        it 'does not create the user and render the form again' do
          post :create, params: { user: { first_name: '', last_name: '', email: '', password: '', password_confirmation: '' } }
          expect(response).to render_template :new
          expect(User.count).to eq 0
        end
      end
    end
  end
end
