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
      let(:user) { Fabricate :user }

      context 'with valid paramenters' do
        it 'updates the password and authenticate the user in the system' do
          expect_any_instance_of(User).to(receive(:save)).twice
          patch :update_default_password, params: { id: user, user: { password: 'foobar', password_confirmation: 'foobar' } }
          expect(response).to redirect_to root_path
        end
      end

      context 'with invalid paramenters' do
        context 'when the password and the confirmation do not match' do
          it 'updates the password and authenticate the user in the system' do
            expect_any_instance_of(User).not_to(receive(:save))
            patch :update_default_password, params: { id: user, user: { password: 'bla', password_confirmation: 'xpto' } }
            expect(response).to render_template :edit_default_password
            expect(flash[:error]).to eq assigns(:user).errors.full_messages.join(', ')
          end
        end

        context 'when the password and the confirmation are blank' do
          it 'updates the password and authenticate the user in the system' do
            expect_any_instance_of(User).not_to(receive(:save))
            patch :update_default_password, params: { id: user, user: { password: '', password_confirmation: '' } }
            expect(response).to render_template :edit_default_password
            expect(flash[:error]).to eq assigns(:user).errors.full_messages.join(', ')
          end
        end

        context 'when the user does not exist' do
          it 'updates the password and authenticate the user in the system' do
            expect_any_instance_of(User).not_to(receive(:save))
            patch :update_default_password, params: { id: 'foo', user: { password: 'foobar', password_confirmation: 'foobar' } }
            expect(response).to have_http_status :not_found
          end
        end
      end
    end
  end

  context 'authorized' do
    context 'as a normal user' do
      let!(:user) { Fabricate :user, role: :user }

      before { sign_in user }

      pending 'when the user is not the same as the signed user'

      describe 'GET #show' do
        context 'with an existent user' do
          context 'with only one event available for date' do
            let!(:event) { Fabricate :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }

            before { get :show, params: { id: user.id } }

            it { expect(assigns(:user)).to eq user }
            it { expect(assigns(:events_for_today)).to match_array [event] }
            it { expect(response).to render_template :show }
          end

          context 'with two events available for date and one unavaiable' do
            let!(:event) { Fabricate :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
            let!(:other_event) { Fabricate :event, start_date: Time.zone.yesterday, end_date: 5.days.from_now }
            let!(:already_attending) { Fabricate :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
            let!(:attendance) { Fabricate(:attendance, user: user, event: already_attending) }
            let!(:cancelled_attendance) { Fabricate(:attendance, user: user, event: other_event, status: :cancelled) }

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

        context 'with a different user' do
          let!(:other_user) { Fabricate :user, role: :user }

          before { get :show, params: { id: other_user } }

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

        context 'with a different user' do
          let!(:other_user) { Fabricate :user, role: :user }

          before { get :edit, params: { id: other_user } }

          it { expect(response).to have_http_status :not_found }
        end
      end

      describe 'PUT #update' do
        context 'with an existent user' do
          before { put :update, params: { id: user.id, user: { first_name: 'xpto', last_name: 'bla', email: 'xpto@bla.com', gender: :transgender_woman, education_level: :tec_secondary, ethnicity: :black, disability: :hearing_impairment, birth_date: Date.new(2006, 6, 29) } } }

          it 'updates the informed user' do
            expect(User.last.first_name).to eq 'xpto'
            expect(User.last.last_name).to eq 'bla'
            expect(User.last.email).to eq 'xpto@bla.com'
            expect(User.last.birth_date).to eq Date.new(2006, 6, 29)
            expect(User.last.gender).to eq 'transgender_woman'
            expect(User.last.education_level).to eq 'tec_secondary'
            expect(User.last.ethnicity).to eq 'black'
            expect(User.last.disability).to eq 'hearing_impairment'
          end
        end

        context 'with an inexistent user' do
          before { put :update, params: { id: 'foo', user: { first_name: 'xpto', last_name: 'bla', email: 'xpto@bla.com' } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'with failed update attributes' do
          it 'does not update and re-render the form with the errors' do
            put :update, params: { id: user.id, user: { first_name: '' } }
            expect(response).to render_template :edit
            expect(User.last.first_name).to eq user.first_name
            expect(User.last.last_name).to eq user.last_name
            expect(User.last.email).to eq user.email
            expect(flash[:error]).to eq 'Nome: não pode ficar em branco'
          end
        end

        context 'with a different user' do
          let!(:other_user) { Fabricate :user, role: :user }

          before { put :update, params: { id: other_user } }

          it { expect(response).to have_http_status :not_found }
        end
      end

      describe 'GET #index' do
        before { get :index }

        it { expect(response).to have_http_status :not_found }
      end

      describe 'PATCH #update_to_organizer' do
        before { patch :update_to_organizer, params: { id: user } }

        it { expect(response).to have_http_status :not_found }
      end

      describe 'PATCH #update_to_admin' do
        before { patch :update_to_admin, params: { id: user } }

        it { expect(response).to have_http_status :not_found }
      end
    end

    context 'as admin' do
      let(:admin) { Fabricate :user, role: :admin }

      before { sign_in admin }

      context 'valid parameters' do
        describe 'GET #index' do
          it 'assign the variables and renders template' do
            expect(UserRepository.instance).to(receive(:search_engine)).and_return([admin])
            get :index
            expect(response).to render_template :index
          end
        end

        describe 'GET #search_users' do
          it 'assign the variables and renders template' do
            expect(UserRepository.instance).to(receive(:search_engine)).and_return([admin])
            get :search_users, xhr: true
            expect(response).to render_template 'users/search_users'
          end
        end

        describe 'PATCH #update_to_organizer' do
          context 'when the user is organizer' do
            let(:organizer) { Fabricate(:user, role: :organizer) }

            before { patch :update_to_organizer, params: { id: organizer } }

            it 'updates the role and redirects' do
              expect(organizer.reload.organizer?).to be false
              expect(response).to redirect_to users_path
            end
          end

          context 'when the user is not an organizer' do
            let(:user) { Fabricate :user }

            before { patch :update_to_organizer, params: { id: user } }

            it 'updates the role and redirects' do
              expect(user.reload.organizer?).to be true
              expect(response).to redirect_to users_path
            end
          end
        end

        describe 'PATCH #update_to_admin' do
          context 'when the user is admin' do
            let(:admin) { Fabricate :user, role: :admin }

            before { patch :update_to_admin, params: { id: admin } }

            it { expect(admin.reload.admin?).to be false }
          end

          context 'when the user is not an admin' do
            let(:user) { Fabricate :user }

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

      describe 'GET #show' do
        context 'with a different user' do
          let!(:other_user) { Fabricate :user, role: :user }

          before { get :show, params: { id: other_user } }

          it { expect(response).to render_template :show }
        end
      end

      describe 'GET #edit' do
        context 'with a different user' do
          let!(:other_user) { Fabricate :user, role: :user }

          before { get :edit, params: { id: other_user } }

          it { expect(response).to render_template :edit }
        end
      end

      describe 'PUT #update' do
        context 'with a different user' do
          let!(:other_user) { Fabricate :user, role: :user }

          before { put :update, params: { id: other_user, user: { first_name: 'xpto', last_name: 'bla', email: 'xpto@bla.com' } } }

          it { expect(response).to redirect_to user_path(other_user) }
        end
      end
    end
  end
end
