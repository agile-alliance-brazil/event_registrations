describe RegistrationPeriodsController, type: :controller do
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
  end

  context 'logged as normal user' do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    describe 'GET #new' do
      it 'redirects to login' do
        get :new, event_id: 'foo'
        expect(response).to redirect_to root_path
      end
    end

    describe 'POST #create' do
      it 'redirects to login' do
        post :create, event_id: 'foo'
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
          expect(assigns(:registration_period)).to be_a_new RegistrationPeriod
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
        it 'creates the period and redirects to event' do
          start_date = Time.zone.now
          end_date = 1.week.from_now
          price = 100

          post :create, event_id: event, registration_period: { title: 'foo', start_at: start_date, end_at: end_date, price: price }
          period_persisted = RegistrationPeriod.last
          registration_period = assigns(:registration_period)
          expect(period_persisted.title).to eq 'foo'
          expect(period_persisted.start_at.utc.to_i).to eq start_date.to_i
          expect(period_persisted.end_at.utc.to_i).to eq end_date.to_i
          expect(period_persisted.price).to eq Money.new(price * 100, :BRL)
          expect(response).to redirect_to new_event_registration_period_path(event, registration_period)
        end
      end

      context 'with invalid parameters' do
        context 'and invalid period params' do
          it 'renders form with the errors' do
            post :create, event_id: event, registration_period: { title: '' }
            period = assigns(:registration_period)

            expect(period).to be_a RegistrationPeriod
            expect(period.errors.full_messages).to eq ['Title não pode ficar em branco', 'Start at não pode ficar em branco', 'End at não pode ficar em branco']
            expect(response).to render_template :new
          end
        end

        context 'and invalid event' do
          it 'renders 404' do
            post :create, event_id: 'foo', registration_period: { title: '' }
            expect(response).to have_http_status 404
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:event) { FactoryGirl.create :event }
      let!(:period) { FactoryGirl.create :registration_period, event: event }

      context 'with valid parameters' do
        context 'and responding to HTML' do
          it 'deletes the period and redirects to event show' do
            delete :destroy, event_id: event.id, id: period
            expect(response).to redirect_to event_path(event)
            expect(RegistrationPeriod.count).to eq 0
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
            delete :destroy, event_id: 'foo', id: period
            expect(response.status).to eq 404
          end
        end
      end
    end
  end
end
