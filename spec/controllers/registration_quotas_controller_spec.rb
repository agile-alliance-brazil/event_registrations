describe RegistrationQuotasController, type: :controller do
  context 'ability stuff' do
    describe '#resource' do
      it { expect(controller.send(:resource_class)).to eq RegistrationQuota }
    end
  end

  context 'unauthenticated' do
    describe 'GET #new' do
      it 'redirects to login' do
        get :new, event_id: 'foo'
        expect(response).to redirect_to login_path
      end
    end
    describe 'POST #create' do
      it 'redirects to login' do
        post :create, event_id: 'foo'
        expect(response).to redirect_to login_path
      end
    end
    describe 'DELETE #destroy' do
      it 'redirects to login' do
        delete :destroy, event_id: 'foo', id: 'foo'
        expect(response).to redirect_to login_path
      end
    end
  end

  context 'logged as normal user' do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    describe 'GET #new' do
      it 'redirects to root' do
        get :new, event_id: 'foo'
        expect(response).to redirect_to root_path
      end
    end

    describe 'POST #create' do
      it 'redirects to root' do
        post :create, event_id: 'foo'
        expect(response).to redirect_to root_path
      end
    end

    describe 'DELETE #destroy' do
      it 'redirects to root' do
        delete :destroy, event_id: 'foo', id: 'foo'
        expect(response).to redirect_to root_path
      end
    end
  end

  context 'logged as admin user' do
    let(:admin) { FactoryGirl.create(:admin) }
    before { sign_in admin }

    describe 'GET #new' do
      context 'with a valid event' do
        let!(:event) { FactoryGirl.create :event }
        it 'assigns the variables and render the template' do
          get :new, event_id: event
          expect(assigns(:event)).to eq event
          expect(assigns(:registration_quota)).to be_a_new RegistrationQuota
          expect(response).to render_template :new
        end
      end
      context 'with an invalid event' do
        it 'renders 404' do
          get :new, event_id: 'foo'
          expect(response).to have_http_status 404
        end
      end
    end

    describe 'POST #create' do
      let(:event) { FactoryGirl.create :event }
      context 'with valid parameters' do
        it 'creates the quota and redirects to event' do
          price = 100
          post :create, event_id: event, registration_quota: { order: 1, price: price, quota: 45 }
          quota_persisted = RegistrationQuota.last
          registration_quota = assigns(:registration_quota)
          expect(quota_persisted.order).to eq 1
          expect(quota_persisted.price).to eq Money.new(price * 100, :BRL)
          expect(quota_persisted.quota).to eq 45
          expect(response).to redirect_to new_event_registration_quota_path(event, registration_quota)
        end
      end

      context 'with invalid parameters' do
        context 'and invalid quota params' do
          it 'renders form with the errors' do
            post :create, event_id: event, registration_quota: { bla: 0 }
            quota = assigns(:registration_quota)

            expect(quota).to be_a RegistrationQuota
            expect(quota.errors.full_messages).to eq ['Order não pode ficar em branco', 'Quota não pode ficar em branco']
            expect(response).to render_template :new
          end
        end

        context 'and invalid event' do
          it 'renders 404' do
            post :create, event_id: 'foo', registration_quota: { order: 0 }
            expect(response).to have_http_status 404
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:event) { FactoryGirl.create :event }
      let!(:quota) { FactoryGirl.create :registration_quota, event: event }

      context 'with valid parameters' do
        context 'and responding to HTML' do
          it 'deletes the quota and redirects to event show' do
            delete :destroy, event_id: event.id, id: quota
            expect(response).to redirect_to event_path(event)
            expect(RegistrationQuota.count).to eq 0
          end
        end
      end

      context 'with invalid parameters' do
        context 'and a valid event' do
          it 'responds 404' do
            delete :destroy, event_id: event, id: 'foo'
            expect(response.status).to eq 404
          end
        end
        context 'and a invalid event' do
          it 'responds 404' do
            delete :destroy, event_id: 'foo', id: quota
            expect(response.status).to eq 404
          end
        end
      end
    end
  end
end
