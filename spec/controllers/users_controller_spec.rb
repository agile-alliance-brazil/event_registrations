# frozen_string_literal: true

RSpec.describe UsersController, type: :controller do
  context 'unauthorized' do
    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #index' do
      before { get :index }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PATCH #update_to_organizer' do
      before { patch :update_to_organizer, params: { id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PATCH #update_to_admin' do
      before { patch :update_to_admin, params: { id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #update_default_password' do
      let(:user) { FactoryBot.create :user }
      context 'with valid paramenters' do
        it 'updates the password and authenticate the user in the system' do
          User.any_instance.expects(:save).twice
          patch :update_default_password, params: { id: user, user: { password: 'foobar', password_confirmation: 'foobar' } }
          expect(response).to redirect_to root_path
        end
      end
      context 'with invalid paramenters' do
        context 'when the password and the confirmation do not match' do
          it 'updates the password and authenticate the user in the system' do
            User.any_instance.expects(:save).never
            patch :update_default_password, params: { id: user, user: { password: 'bla', password_confirmation: 'xpto' } }
            expect(response).to render_template :edit_default_password
            expect(flash[:error]).to eq assigns(:user).errors.full_messages.join(', ')
          end
        end
        context 'when the password and the confirmation are blank' do
          it 'updates the password and authenticate the user in the system' do
            User.any_instance.expects(:save).never
            patch :update_default_password, params: { id: user, user: { password: '', password_confirmation: '' } }
            expect(response).to render_template :edit_default_password
            expect(flash[:error]).to eq assigns(:user).errors.full_messages.join(', ')
          end
        end
        context 'when the user does not exist' do
          it 'updates the password and authenticate the user in the system' do
            User.any_instance.expects(:save).never
            patch :update_default_password, params: { id: 'foo', user: { password: 'foobar', password_confirmation: 'foobar' } }
            expect(response).to have_http_status :not_found
          end
        end
      end
    end
  end

  context 'authorized' do
    context 'as a normal user' do
      let!(:user) { FactoryBot.create :user }
      before { sign_in user }

      pending 'when the user is not the same as the signed user'

      describe 'GET #show' do
        context 'with an existent user' do
          context 'with only one event available for date' do
            let!(:event) { FactoryBot.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
            before { get :show, params: { id: user.id } }
            it { expect(assigns(:user)).to eq user }
            it { expect(assigns(:events_for_today)).to match_array [event] }
            it { expect(response).to render_template :show }
          end
          context 'with two events available for date and one unavaiable' do
            let!(:event) { FactoryBot.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
            let!(:other_event) { FactoryBot.create :event, start_date: Time.zone.yesterday, end_date: 5.days.from_now }
            let!(:already_attending) { FactoryBot.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
            let!(:attendance) { FactoryBot.create(:attendance, user: user, event: already_attending) }
            let!(:cancelled_attendance) { FactoryBot.create(:attendance, user: user, event: other_event, status: :cancelled) }
            before { get :show, params: { id: user.id } }
            it { expect(assigns(:user)).to eq user }
            it { expect(assigns(:events_for_today)).to match_array [event, other_event] }
            it { expect(response).to render_template :show }
          end
        end

        context 'with an inexistent user' do
          before { get :show, params: { id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
      end

      describe 'GET #edit' do
        context 'with an existent user' do
          before { get :edit, params: { id: user.id } }
          it { expect(assigns(:user)).to eq user }
          it { expect(response).to render_template :edit }
        end

        context 'with an inexistent user' do
          before { get :edit, params: { id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
      end

      describe 'PUT #update' do
        let(:valid_params) { { first_name: 'xpto', last_name: 'bla', email: 'xpto@bla.com' } }

        context 'with an existent user' do
          before { put :update, params: { id: user.id, user: valid_params } }
          it { expect(User.last.first_name).to eq 'xpto' }
          it { expect(User.last.last_name).to eq 'bla' }
          it { expect(User.last.email).to eq 'xpto@bla.com' }
        end

        context 'with an inexistent user' do
          before { put :update, params: { id: 'foo', user: valid_params } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'with failed update attributes' do
          it 'does not update and re-render the form with the errors' do
            put :update, params: { id: user.id, user: { first_name: '' } }
            expect(response).to render_template :edit
            expect(User.last.first_name).to eq user.first_name
            expect(User.last.last_name).to eq user.last_name
            expect(User.last.email).to eq user.email
          end
        end
      end

      describe 'GET #index' do
        before { get :index }
        it { expect(response).to have_http_status :not_found }
      end

      describe 'PATCH #update_to_organizer' do
        before { patch :update_to_organizer, params: { id: user }, xhr: true }
        it { expect(response).to have_http_status :not_found }
      end

      describe 'PATCH #update_to_admin' do
        before { patch :update_to_admin, params: { id: user }, xhr: true }
        it { expect(response).to have_http_status :not_found }
      end
    end

    context 'as admin' do
      let(:admin) { FactoryBot.create :admin }
      before { sign_in admin }

      describe 'GET #index' do
        context 'html response' do
          it 'assign the variables and renders template' do
            UserRepository.instance.expects(:search_engine).returns([admin])
            get :index
            expect(response).to render_template :index
          end
        end

        context 'ajax request' do
          it 'renders the template' do
            get :index, xhr: true
            expect(response).to have_http_status :ok
            expect(response).to render_template 'users/index.js.haml'
          end
        end
      end

      context 'valid parameters' do
        describe 'PATCH #update_to_organizer' do
          context 'when the user is organizer' do
            let(:organizer) { FactoryBot.create :organizer }
            before { patch :update_to_organizer, params: { id: organizer }, xhr: true }
            it { expect(response).to render_template 'users/user' }
            it { expect(organizer.reload.organizer?).to be true }
          end
          context 'when the user is not an organizer' do
            let(:user) { FactoryBot.create :user }
            before { patch :update_to_organizer, params: { id: user }, xhr: true }
            it { expect(user.reload.organizer?).to be true }
          end
        end
        describe 'PATCH #update_to_admin' do
          context 'when the user is admin' do
            let(:admin) { FactoryBot.create :admin }
            before { patch :update_to_admin, params: { id: admin }, xhr: true }
            it { expect(admin.reload.admin?).to be true }
          end
          context 'when the user is not an admin' do
            let(:user) { FactoryBot.create :user }
            before { patch :update_to_admin, params: { id: user }, xhr: true }
            it { expect(user.reload.admin?).to be true }
          end
        end
      end

      context 'invalid parameters' do
        describe 'PATCH #update_to_organizer' do
          before { patch :update_to_organizer, params: { id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        describe 'PATCH #update_to_admin' do
          before { patch :update_to_admin, params: { id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
