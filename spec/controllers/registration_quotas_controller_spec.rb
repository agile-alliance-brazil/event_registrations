# frozen_string_literal: true

describe RegistrationQuotasController, type: :controller do
  context 'ability stuff' do
    describe '#resource' do
      it { expect(controller.send(:resource_class)).to eq RegistrationQuota }
    end
  end

  context 'unauthenticated' do
    describe 'GET #new' do
      it 'redirects to login' do
        get :new, params: { event_id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
    describe 'POST #create' do
      it 'redirects to login' do
        post :create, params: { event_id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
    describe 'DELETE #destroy' do
      it 'redirects to login' do
        delete :destroy, params: { event_id: 'foo', id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
    describe 'GET #edit' do
      it 'redirects to login' do
        get :edit, params: { event_id: 'foo', id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
    describe 'PUT #update' do
      it 'redirects to login' do
        put :update, params: { event_id: 'foo', id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
  end

  context 'logged as normal user' do
    let(:user) { FactoryBot.create(:user) }
    before { sign_in user }

    describe 'GET #new' do
      it 'redirects to root' do
        get :new, params: { event_id: 'foo' }
        expect(response).to redirect_to root_path
      end
    end
    describe 'POST #create' do
      it 'redirects to root' do
        post :create, params: { event_id: 'foo' }
        expect(response).to redirect_to root_path
      end
    end
    describe 'DELETE #destroy' do
      it 'redirects to root' do
        delete :destroy, params: { event_id: 'foo', id: 'foo' }
        expect(response).to redirect_to root_path
      end
    end
    describe 'GET #edit' do
      it 'redirects to root' do
        get :edit, params: { event_id: 'foo', id: 'foo' }
        expect(response).to redirect_to root_path
      end
    end
    describe 'PUT #update' do
      it 'redirects to login' do
        put :update, params: { event_id: 'foo', id: 'foo' }
        expect(response).to redirect_to root_path
      end
    end
  end

  context 'logged as admin user' do
    let(:admin) { FactoryBot.create(:admin) }
    before { sign_in admin }

    describe 'GET #new' do
      context 'with a valid event' do
        let!(:event) { FactoryBot.create :event }
        it 'assigns the variables and render the template' do
          get :new, params: { event_id: event }
          expect(assigns(:event)).to eq event
          expect(assigns(:registration_quota)).to be_a_new RegistrationQuota
          expect(response).to render_template :new
        end
      end
      context 'with an invalid event' do
        it 'renders 404' do
          get :new, params: { event_id: 'foo' }
          expect(response).to have_http_status 404
        end
      end
    end

    describe 'POST #create' do
      let(:event) { FactoryBot.create :event }
      context 'with valid parameters' do
        it 'creates the quota and redirects to event' do
          post :create, params: { event_id: event, registration_quota: { order: 1, price: 100, quota: 45 } }
          quota_persisted = RegistrationQuota.last
          registration_quota = assigns(:registration_quota)
          expect(quota_persisted.order).to eq 1
          expect(quota_persisted.price.to_d).to eq 100
          expect(quota_persisted.quota).to eq 45
          expect(response).to redirect_to new_event_registration_quota_path(event, registration_quota)
        end
      end

      context 'with invalid parameters' do
        context 'and invalid quota params' do
          it 'renders form with the errors' do
            post :create, params: { event_id: event, registration_quota: { bla: 0 } }
            quota = assigns(:registration_quota)

            expect(quota).to be_a RegistrationQuota
            expect(quota.errors.full_messages).to eq ['Order não pode ficar em branco', 'Quota não pode ficar em branco']
            expect(response).to render_template :new
          end
        end

        context 'and invalid event' do
          it 'renders 404' do
            post :create, params: { event_id: 'foo', registration_quota: { order: 0 } }
            expect(response).to have_http_status 404
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:event) { FactoryBot.create :event }
      let!(:quota) { FactoryBot.create :registration_quota, event: event }

      context 'with valid parameters' do
        context 'and responding to HTML' do
          it 'deletes the quota and redirects to event show' do
            delete :destroy, params: { event_id: event.id, id: quota }
            expect(response).to redirect_to event_path(event)
            expect(RegistrationQuota.count).to eq 0
          end
        end
      end

      context 'with invalid parameters' do
        context 'and a valid event' do
          it 'responds 404' do
            delete :destroy, params: { event_id: event, id: 'foo' }
            expect(response.status).to eq 404
          end
        end
        context 'and an invalid event' do
          it 'responds 404' do
            delete :destroy, params: { event_id: 'foo', id: quota }
            expect(response.status).to eq 404
          end
        end
        context 'and a quota for other event' do
          let(:event) { FactoryBot.create :event }
          let(:other_event) { FactoryBot.create :event }
          let(:quota) { FactoryBot.create :registration_quota, event: other_event }
          it 'does not assign the instance variable responds 404' do
            delete :destroy, params: { event_id: event, id: quota }
            expect(assigns(:registration_quota)).to be_nil
            expect(response.status).to eq 404
          end
        end
      end
    end

    describe 'GET #edit' do
      let(:event) { FactoryBot.create :event }
      let(:quota) { FactoryBot.create :registration_quota, event: event }
      context 'with valid IDs' do
        it 'assigns the instance variable and renders the template' do
          get :edit, params: { event_id: event, id: quota }
          expect(assigns(:registration_quota)).to eq quota
          expect(response).to render_template :edit
        end
      end
      context 'with invalid IDs' do
        context 'and no valid event and quota' do
          it 'does not assign the instance variable responds 404' do
            get :edit, params: { event_id: 'foo', id: 'bar' }
            expect(assigns(:registration_quota)).to be_nil
            expect(response.status).to eq 404
          end
        end
        context 'and an invalid event' do
          it 'responds 404' do
            get :edit, params: { event_id: 'foo', id: quota }
            expect(response.status).to eq 404
          end
        end
        context 'and a quota for other event' do
          let(:other_event) { FactoryBot.create :event }
          let(:quota) { FactoryBot.create :registration_quota, event: other_event }
          it 'does not assign the instance variable responds 404' do
            get :edit, params: { event_id: event, id: quota }
            expect(assigns(:registration_quota)).to be_nil
            expect(response.status).to eq 404
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:event) { FactoryBot.create :event }
      let(:quota) { FactoryBot.create :registration_quota, event: event }
      let(:valid_parameters) { { order: 4, price: 300, quota: 32 } }
      context 'with valid parameters' do
        it 'updates and redirects to event show' do
          put :update, params: { event_id: event, id: quota, registration_quota: valid_parameters }
          updated_quota = RegistrationQuota.last
          expect(updated_quota.order).to eq 4
          expect(updated_quota.price.to_d).to eq 300
          expect(updated_quota.quota).to eq 32
          expect(response).to redirect_to event
        end
      end
      context 'with invalid parameters' do
        context 'and valid event and quota, but invalid update parameters' do
          let(:invalid_parameters) { { order: nil, price: nil, quota: nil } }

          it 'does not update and render form with errors' do
            put :update, params: { event_id: event, id: quota, registration_quota: invalid_parameters }
            updated_quota = assigns(:registration_quota)
            expect(updated_quota.errors.full_messages).to eq ['Price não é um número', 'Order não pode ficar em branco', 'Quota não pode ficar em branco']
            expect(response).to render_template :edit
          end
        end

        context 'with invalid IDs' do
          context 'and no valid event and quota' do
            it 'does not assign the instance variable responds 404' do
              put :update, params: { event_id: 'bar', id: 'foo', registration_quota: valid_parameters }
              expect(assigns(:registration_quota)).to be_nil
              expect(response.status).to eq 404
            end
          end
          context 'and an invalid event' do
            it 'responds 404' do
              put :update, params: { event_id: 'bar', id: quota, registration_quota: valid_parameters }
              expect(response.status).to eq 404
            end
          end
          context 'and a quota for other event' do
            let(:other_event) { FactoryBot.create :event }
            let(:quota) { FactoryBot.create :registration_quota, event: other_event }
            it 'does not assign the instance variable responds 404' do
              put :update, params: { event_id: event, id: quota, registration_quota: valid_parameters }
              expect(assigns(:registration_quota)).to be_nil
              expect(response.status).to eq 404
            end
          end
        end
      end
    end
  end
end
