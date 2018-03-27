# frozen_string_literal: true

RSpec.describe UsersController, type: :controller do
  context 'unauthorized' do
    describe 'GET #show' do
      it 'redirects to login path' do
        get :show, params: { id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
    describe 'GET #edit' do
      it 'redirects to login path' do
        get :edit, params: { id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
    describe 'PUT #update' do
      it 'redirects to login path' do
        put :update, params: { id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
    describe 'GET #index' do
      it 'redirects to login path' do
        get :index
        expect(response).to redirect_to login_path
      end
    end
    describe 'PATCH #toggle_organizer' do
      it 'redirects to login path' do
        patch :toggle_organizer, params: { id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
    describe 'PATCH #toggle_admin' do
      it 'redirects to login path' do
        patch :toggle_admin, params: { id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
  end

  context 'authorized' do
    context 'as a normal user' do
      let!(:user) { FactoryBot.create :user }
      before { sign_in user }

      pending 'when the user is not the same as the signed user'

      describe '#show' do
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

      describe '#edit' do
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

      describe '#update' do
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
            expect(flash[:error]).to eq I18n.t('flash.user.edit')
            expect(response).to render_template :edit
            expect(User.last.first_name).to eq user.first_name
            expect(User.last.last_name).to eq user.last_name
            expect(User.last.email).to eq user.email
          end
        end
      end

      describe 'GET #index' do
        it 'redirects to root path' do
          get :index
          expect(response).to redirect_to root_path
        end
      end
      describe 'PATCH #toggle_organizer' do
        before { patch :toggle_organizer, params: { id: 'foo' } }
        it { expect(response).to redirect_to root_path }
      end
      describe 'PATCH #toggle_admin' do
        before { patch :toggle_admin, params: { id: 'foo' } }
        it { expect(response).to redirect_to root_path }
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
            expect(response).to render_template 'users/index.js.haml'
          end
        end
      end

      context 'valid parameters' do
        describe 'PATCH #toggle_organizer' do
          context 'when the user is organizer' do
            let(:organizer) { FactoryBot.create :organizer }
            it 'removes the role' do
              patch :toggle_organizer, params: { id: organizer }, xhr: true
              expect(response).to render_template 'users/user'
              expect(organizer.reload.roles).not_to include('organizer')
            end
          end
          context 'when the user is not an organizer' do
            let(:user) { FactoryBot.create :user }
            before { patch :toggle_organizer, params: { id: user }, xhr: true }
            it { expect(user.reload.roles).to include('organizer') }
          end
        end
        describe 'PATCH #toggle_admin' do
          context 'when the user is admin' do
            let(:admin) { FactoryBot.create :admin }
            it 'removes the role' do
              patch :toggle_admin, params: { id: admin }, xhr: true
              expect(response).to render_template 'users/user'
              expect(admin.reload.roles).not_to include('admin')
            end
          end
          context 'when the user is not an organizer' do
            let(:user) { FactoryBot.create :user }
            before { patch :toggle_admin, params: { id: user }, xhr: true }
            it { expect(user.reload.roles).to include('admin') }
          end
        end
      end

      context 'invalid parameters' do
        describe 'PATCH #toggle_organizer' do
          before { patch :toggle_organizer, params: { id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        describe 'PATCH #toggle_admin' do
          before { patch :toggle_admin, params: { id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
