# frozen_string_literal: true

describe RegistrationPeriodsController, type: :controller do
  context 'ability stuff' do
    describe '#resource' do
      it { expect(controller.send(:resource_class)).to eq RegistrationPeriod }
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
  end

  context 'logged as normal user' do
    let(:user) { FactoryBot.create(:user) }
    before { sign_in user }

    describe 'GET #new' do
      it 'redirects to login' do
        get :new, params: { event_id: 'foo' }
        expect(response).to redirect_to root_path
      end
    end

    describe 'POST #create' do
      it 'redirects to login' do
        post :create, params: { event_id: 'foo' }
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
          expect(assigns(:period)).to be_a_new RegistrationPeriod
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
        it 'creates the period and redirects to event' do
          start_date = Time.zone.now
          end_date = 1.week.from_now
          valid_parameters = { title: 'foo', start_at: start_date, end_at: end_date, price: 100 }

          post :create, params: { event_id: event, registration_period: valid_parameters }
          period_persisted = RegistrationPeriod.last
          registration_period = assigns(:registration_period)
          expect(period_persisted.title).to eq 'foo'
          expect(period_persisted.start_at.utc.to_i).to eq start_date.to_i
          expect(period_persisted.end_at.utc.to_i).to eq end_date.to_i
          expect(period_persisted.price.to_d).to eq 100
          expect(response).to redirect_to new_event_registration_period_path(event, registration_period)
        end
      end

      context 'with invalid parameters' do
        context 'and invalid period params' do
          it 'renders form with the errors' do
            post :create, params: { event_id: event, registration_period: { title: '' } }
            period = assigns(:period)

            expect(period).to be_a RegistrationPeriod
            expect(period.errors.full_messages).to eq ['Title não pode ficar em branco', 'Start at não pode ficar em branco', 'End at não pode ficar em branco']
            expect(response).to render_template :new
          end
        end

        context 'and invalid event' do
          it 'renders 404' do
            post :create, params: { event_id: 'foo', registration_period: { title: '' } }
            expect(response).to have_http_status 404
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:event) { FactoryBot.create :event }
      let!(:period) { FactoryBot.create :registration_period, event: event }

      context 'with valid parameters' do
        context 'and responding to HTML' do
          it 'deletes the period and redirects to event show' do
            delete :destroy, params: { event_id: event.id, id: period }
            expect(response).to redirect_to event_path(event)
            expect(RegistrationPeriod.count).to eq 0
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
        context 'and a invalid event' do
          it 'responds 404' do
            delete :destroy, params: { event_id: 'foo', id: period }
            expect(response.status).to eq 404
          end
        end
      end
    end

    describe 'GET #edit' do
      let(:event) { FactoryBot.create :event }
      let(:period) { FactoryBot.create :registration_period, event: event }
      context 'with valid IDs' do
        it 'assigns the instance variable and renders the template' do
          get :edit, params: { event_id: event, id: period }
          expect(assigns(:period)).to eq period
          expect(response).to render_template :edit
        end
      end
      context 'with invalid IDs' do
        context 'and no valid event and period' do
          it 'does not assign the instance variable responds 404' do
            get :edit, params: { event_id: 'foo', id: 'bar' }
            expect(assigns(:period)).to be_nil
            expect(response.status).to eq 404
          end
        end
        context 'and an invalid event' do
          it 'responds 404' do
            get :edit, params: { event_id: 'foo', id: period }
            expect(response.status).to eq 404
          end
        end
        context 'and a period for other event' do
          let(:other_event) { FactoryBot.create :event }
          let(:period) { FactoryBot.create :registration_period, event: other_event }
          it 'does not assign the instance variable responds 404' do
            get :edit, params: { event_id: event, id: period }
            expect(assigns(:period)).to be_nil
            expect(response.status).to eq 404
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:event) { FactoryBot.create :event }
      let(:period) { FactoryBot.create :registration_period, event: event }
      let(:start_date) { Time.zone.now }
      let(:end_date) { 1.week.from_now }
      let(:valid_parameters) { { title: 'foo', start_at: start_date, end_at: end_date, price: 100 } }
      context 'with valid parameters' do
        it 'updates and redirects to event show' do
          put :update, params: { event_id: event, id: period, registration_period: valid_parameters }
          updated_period = RegistrationPeriod.last
          expect(updated_period.title).to eq 'foo'
          expect(updated_period.start_at.utc.to_i).to eq start_date.to_i
          expect(updated_period.end_at.utc.to_i).to eq end_date.to_i
          expect(updated_period.price.to_d).to eq 100
          expect(response).to redirect_to event
        end
      end
      context 'with invalid parameters' do
        context 'and valid event and period, but invalid update parameters' do
          it 'does not update and render form with errors' do
            put :update, params: { event_id: event, id: period, registration_period: { title: '', start_at: '', end_at: '' } }
            updated_period = assigns(:period)
            expect(updated_period.errors.full_messages).to eq ['Title não pode ficar em branco', 'Start at não pode ficar em branco', 'End at não pode ficar em branco']
            expect(response).to render_template :edit
          end
        end

        context 'with invalid IDs' do
          context 'and no valid event and period' do
            it 'does not assign the instance variable responds 404' do
              put :update, params: { event_id: 'bar', id: 'foo', registration_period: valid_parameters }
              expect(assigns(:registration_period)).to be_nil
              expect(response.status).to eq 404
            end
          end
          context 'and an invalid event' do
            it 'responds 404' do
              put :update, params: { event_id: 'bar', id: period, registration_period: valid_parameters }
              expect(response.status).to eq 404
            end
          end
          context 'and a period for other event' do
            let(:other_event) { FactoryBot.create :event }
            let(:period) { FactoryBot.create :registration_period, event: other_event }
            it 'does not assign the instance variable responds 404' do
              put :update, params: { event_id: event, id: period, registration_period: valid_parameters }
              expect(assigns(:period)).to be_nil
              expect(response.status).to eq 404
            end
          end
        end
      end
    end
  end
end
