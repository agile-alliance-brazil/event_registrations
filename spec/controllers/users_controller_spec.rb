describe UsersController, type: :controller do
  context 'unauthorized' do
    describe 'GET #show' do
      it 'redirects to login path' do
        get :show, id: 'foo'
        expect(response).to redirect_to login_path
      end
    end
    describe 'GET #edit' do
      it 'redirects to login path' do
        get :edit, id: 'foo'
        expect(response).to redirect_to login_path
      end
    end
    describe 'PUT #update' do
      it 'redirects to login path' do
        put :update, id: 'foo'
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
        patch :toggle_organizer, id: 'foo'
        expect(response).to redirect_to login_path
      end
    end
    describe 'PATCH #toggle_admin' do
      it 'redirects to login path' do
        patch :toggle_admin, id: 'foo'
        expect(response).to redirect_to login_path
      end
    end
  end

  context 'authorized' do
    context 'as a normal user' do
      let!(:user) { FactoryGirl.create :user }
      before { sign_in user }

      describe '#show' do
        context 'with an existent user' do
          context 'with only one event available for date' do
            let!(:event) { FactoryGirl.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
            before { get :show, id: user.id }
            it { expect(assigns(:user)).to eq user }
            it { expect(assigns(:events_for_today)).to match_array [event] }
            it { expect(response).to render_template :show }
          end
        end

        context 'with an inexistent user' do
          before { get :show, id: 'foo' }
          it { expect(assigns(:user)).to be_nil }
          it { expect(response.status).to eq 302 }
          it { expect(flash[:error]).to eq I18n.t('flash.unauthorised') }
        end
      end

      describe '#edit' do
        context 'with an existent user' do
          before { get :edit, id: user.id }
          it { expect(assigns(:user)).to eq user }
          it { expect(response).to render_template :edit }
        end

        context 'with an inexistent user' do
          before { get :edit, id: 'foo' }
          it { expect(assigns(:user)).to be_nil }
          it { expect(response.status).to eq 302 }
          it { expect(flash[:error]).to eq I18n.t('flash.unauthorised') }
        end
      end

      describe '#update' do
        let(:valid_params) { { first_name: 'xpto', last_name: 'bla', email: 'xpto@bla.com', email_confirmation: 'xpto@bla.com' } }

        context 'with an existent user' do
          before { put :update, id: user.id, user: valid_params }
          it { expect(User.last.first_name).to eq 'xpto' }
          it { expect(User.last.last_name).to eq 'bla' }
          it { expect(User.last.email).to eq 'xpto@bla.com' }
        end

        context 'with an inexistent user' do
          before { put :update, id: 'foo', user: valid_params }
          it { expect(assigns(:user)).to be_nil }
          it { expect(response.status).to eq 302 }
          it { expect(flash[:error]).to eq I18n.t('flash.unauthorised') }

          it { expect(User.last.first_name).to eq user.first_name }
          it { expect(User.last.last_name).to eq user.last_name }
          it { expect(User.last.email).to eq user.email }
        end

        context 'with failed update attributes' do
          before { put :update, id: user.id, user: { first_name: '' } }
          it { expect(flash[:error]).to eq I18n.t('flash.user.edit') }
          it { expect(response).to render_template :edit }

          it { expect(User.last.first_name).to eq user.first_name }
          it { expect(User.last.last_name).to eq user.last_name }
          it { expect(User.last.email).to eq user.email }
        end
      end

      describe 'GET #index' do
        it 'redirects to root path' do
          get :index
          expect(response).to redirect_to root_path
        end
      end
      describe 'PATCH #toggle_organizer' do
        it 'redirects to root path' do
          patch :toggle_organizer, id: 'foo'
          expect(response).to redirect_to root_path
        end
      end
      describe 'PATCH #toggle_admin' do
        it 'redirects to login path' do
          patch :toggle_admin, id: 'foo'
          expect(response).to redirect_to root_path
        end
      end
    end

    context 'as admin' do
      let(:admin) { FactoryGirl.create :admin }
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
            xhr :get, :index
            expect(response).to render_template 'users/index.js.haml'
          end
        end
      end

      describe 'PATCH #toggle_organizer' do
        context 'when the user is organizer' do
          let(:organizer) { FactoryGirl.create :organizer }
          it 'removes the role' do
            xhr :patch, :toggle_organizer, id: organizer
            expect(response).to render_template 'users/user'
            expect(organizer.reload.roles).not_to include('organizer')
          end
        end
        context 'when the user is not an organizer' do
          let(:user) { FactoryGirl.create :user }
          before { xhr :patch, :toggle_organizer, id: user }
          it { expect(user.reload.roles).to include('organizer') }
        end
      end
      describe 'PATCH #toggle_admin' do
        context 'when the user is admin' do
          let(:admin) { FactoryGirl.create :admin }
          it 'removes the role' do
            xhr :patch, :toggle_admin, id: admin
            expect(response).to render_template 'users/user'
            expect(admin.reload.roles).not_to include('admin')
          end
        end
        context 'when the user is not an organizer' do
          let(:user) { FactoryGirl.create :user }
          before { xhr :patch, :toggle_admin, id: user }
          it { expect(user.reload.roles).to include('admin') }
        end
      end
    end
  end
end
