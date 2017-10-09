RSpec.describe EventsController, type: :controller do
  context 'ability stuff' do
    describe '#resource_class' do
      it { expect(controller.send(:resource_class)).to eq Event }
    end
    describe '#resource' do
      let(:event) { FactoryGirl.create :event }
      before { get :show, params: { id: event } }
      it { expect(controller.send(:resource)).to eq event }
    end
  end

  context 'unauthenticated' do
    describe 'GET #index' do
      context 'without events at the right period' do
        before { get :index }
        it { expect(assigns(:events)).to match_array [] }
      end

      context 'with events' do
        let!(:event) { FactoryGirl.create(:event, name: 'Foo', start_date: Time.zone.today - 1, end_date: 1.month.from_now) }

        context 'and one event at the right period' do
          before { get :index }
          it { expect(assigns(:events)).to match_array [event] }
        end

        context 'and two at the right period' do
          let!(:other_event) { FactoryGirl.create(:event, start_date: Time.zone.today - 1, end_date: 2.months.from_now) }
          before { get :index }
          it { expect(assigns(:events)).to match_array [event, other_event] }
        end

        context 'and one at the right period and other not' do
          let!(:out) { FactoryGirl.create(:event, start_date: 2.years.ago, end_date: 1.year.ago) }
          before { get :index }
          it { expect(assigns(:events)).to match_array [event] }
        end

        context 'and two at the right period and other not' do
          let!(:other_event) { FactoryGirl.create(:event, start_date: Time.zone.today - 1, end_date: 2.months.from_now) }
          let!(:out) { FactoryGirl.create(:event, start_date: 2.years.ago, end_date: 1.year.ago) }

          before { get :index }
          it { expect(assigns(:events)).to match_array [event, other_event] }
        end
      end
    end

    describe 'GET #list_archived' do
      it 'redirects to login' do
        get :list_archived
        is_expected.to redirect_to login_path
      end
    end

    describe 'GET #new' do
      it 'redirects to login' do
        get :new
        is_expected.to redirect_to login_path
      end
    end

    describe 'POST #create' do
      it 'redirects to login' do
        post :create
        is_expected.to redirect_to login_path
      end
    end

    describe 'DELETE destroy' do
      it 'redirects to login' do
        delete :destroy, params: { id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end

    describe 'PATCH #add_organizer' do
      it 'redirects to login' do
        patch :add_organizer, params: { id: 'foo' }, xhr: true
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #edit' do
      it 'redirects to login' do
        get :edit, params: { id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end

    describe 'PUT #update' do
      it 'redirects to login' do
        put :update, params: { id: 'foo' }
        expect(response).to redirect_to login_path
      end
    end
  end

  context 'logged as normal user' do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }

    describe 'GET #list_archived' do
      it 'redirects to root' do
        get :list_archived
        expect(response).to redirect_to root_path
      end
    end

    describe 'GET #new' do
      it 'redirects to root' do
        get :new
        expect(response).to redirect_to root_path
      end
    end

    describe 'POST #create' do
      it 'redirects to root' do
        post :create
        expect(response).to redirect_to root_path
      end
    end

    describe 'DELETE #destroy' do
      it 'redirects to root' do
        delete :destroy, params: { id: 'foo' }
        expect(response).to redirect_to root_path
      end
    end

    describe 'PATCH #add_organizer' do
      it 'redirects to root' do
        patch :add_organizer, params: { id: 'foo' }, xhr: true
        expect(response).to redirect_to root_path
      end
    end

    describe 'GET #edit' do
      it 'redirects to root' do
        get :edit, params: { id: 'foo' }
        expect(response).to redirect_to root_path
      end
    end

    describe 'PUT #update' do
      it 'redirects to root' do
        put :update, params: { id: 'foo' }
        expect(response).to redirect_to root_path
      end
    end
  end

  context 'logged as organizer' do
    let(:organizer) { FactoryGirl.create :organizer }
    before { sign_in organizer }

    describe 'DELETE #destroy' do
      it 'redirects to root' do
        delete :destroy, params: { id: 'foo' }
        expect(response).to redirect_to root_path
      end
    end

    context 'when is organizing' do
      let(:event) { FactoryGirl.create :event, organizers: [organizer] }
      describe 'GET #edit' do
        context 'and valid event ID' do
          it 'assigns the instance variable and renders the template' do
            get :edit, params: { id: event }
            expect(response).to render_template :edit
            expect(assigns(:event)).to eq event
          end
        end
        context 'and invalid event ID' do
          it 'responds 404' do
            get :edit, params: { id: 'foo' }
            expect(response).to have_http_status 404
          end
        end
      end

      describe 'PUT #update' do
        context 'with valid event ID' do
          it 'updates the event' do
            start_date = Time.zone.now
            end_date = 1.week.from_now
            put :update, params: { id: event, event: { name: 'name', attendance_limit: 65, days_to_charge: 5, start_date: start_date, end_date: end_date, main_email_contact: 'contact@foo.com.br', full_price: 278, price_table_link: 'http://xpto', logo: 'bla.jpg' } }
            event_updated = Event.last
            expect(response).to redirect_to event
            expect(event_updated.name).to eq 'name'
            expect(event_updated.attendance_limit).to eq 65
            expect(event_updated.days_to_charge).to eq 5
            expect(event_updated.start_date.utc.to_i).to eq start_date.to_i
            expect(event_updated.end_date.utc.to_i).to eq end_date.to_i
            expect(event_updated.full_price).to eq 278
            expect(event_updated.price_table_link).to eq 'http://xpto'
            expect(event_updated.logo).to eq 'bla.jpg'
          end
        end
        context 'with invalid event parameters' do
          before { put :update, params: { id: event, event: { name: '', attendance_limit: nil, days_to_charge: nil, start_date: '', end_date: '', full_price: '', price_table_link: '' } } }
          it 'renderes the form with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:event).errors.full_messages).to eq ['Inicia em não pode ficar em branco', 'Termina em não pode ficar em branco', 'Preço cheio não pode ficar em branco', 'Nome não pode ficar em branco', 'Capacidade não pode ficar em branco']
          end
        end
        context 'with invalid event ID' do
          it 'responds 404' do
            get :edit, params: { id: 'foo' }
            expect(response).to have_http_status 404
          end
        end
      end
    end

    context 'when is not organizing' do
      let(:event) { FactoryGirl.create :event }
      describe 'GET #edit' do
        it 'redirects to root' do
          get :edit, params: { id: event }
          expect(response).to redirect_to root_path
        end
      end

      describe 'PUT #update' do
        it 'redirects to root' do
          put :update, params: { id: event }
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  context 'logged as admin' do
    let(:admin) { FactoryGirl.create(:admin) }
    before { sign_in admin }

    describe 'GET #list_archived' do
      context 'without events' do
        before { get :list_archived }
        it { expect(assigns(:events)).to match_array [] }
        it { expect(response).to render_template :index }
      end

      context 'having events' do
        let!(:event) { FactoryGirl.create(:event, name: 'Foo', start_date: 3.months.ago, end_date: 2.months.ago) }
        let!(:other_event) { FactoryGirl.create(:event, start_date: 2.months.ago, end_date: 1.month.ago) }

        before { get :list_archived }
        it { expect(assigns(:events)).to eq [other_event, event] }
      end
    end

    describe 'GET #new' do
      it 'assigns the event and render the new template' do
        get :new
        expect(assigns(:event)).to be_a_new Event
        expect(response).to render_template :new
      end
    end

    describe 'POST #create' do
      context 'with valid parameters' do
        it 'creates the event and redirects to index of events' do
          start_date = Time.zone.now
          end_date = 1.week.from_now
          post :create, params: { event: { name: 'foo', attendance_limit: 10, days_to_charge: 3, start_date: start_date, end_date: end_date, main_email_contact: 'contact@foo.com.br', full_price: 100, price_table_link: 'http://bla', logo: 'bla.jpg' } }
          expect(Event.count).to eq 1
          event_persisted = Event.last
          expect(event_persisted.name).to eq 'foo'
          expect(event_persisted.attendance_limit).to eq 10
          expect(event_persisted.days_to_charge).to eq 3
          expect(event_persisted.start_date.utc.to_i).to eq start_date.to_i
          expect(event_persisted.end_date.utc.to_i).to eq end_date.to_i
          expect(event_persisted.full_price).to eq 100
          expect(event_persisted.price_table_link).to eq 'http://bla'
          expect(event_persisted.logo).to eq 'bla.jpg'

          expect(response).to redirect_to event_path(event_persisted)
        end
      end

      context 'with invalid parameters' do
        subject(:event) { assigns(:event) }
        before { post :create, params: { event: { name: '' } } }

        it 'renders form with the errors' do
          expect(event).to be_a Event
          expect(event.errors.full_messages).to eq ['Inicia em não pode ficar em branco', 'Termina em não pode ficar em branco', 'Preço cheio não pode ficar em branco', 'Nome não pode ficar em branco', 'Contato para notificações não pode ficar em branco', 'Capacidade não pode ficar em branco']
          expect(response).to render_template :new
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'with valid parameters' do
        context 'and responding to HTML' do
          let!(:event) { FactoryGirl.create :event }
          it 'deletes the event and redirects to events index' do
            delete :destroy, params: { id: event.id }
            expect(response).to redirect_to events_path
            expect(Event.count).to eq 0
          end
        end
      end

      context 'with invalid parameters' do
        it 'responds 404' do
          delete :destroy, params: { id: 'foo' }
          expect(response.status).to eq 404
        end
      end
    end

    describe 'PATCH #add_organizer' do
      let(:event) { FactoryGirl.create :event }
      context 'with invalid parameters' do
        context 'and invalid event' do
          it 'responds 404' do
            patch :add_organizer, params: { id: 'foo' }, xhr: true
            expect(response.status).to eq 404
          end
        end
        context 'and invalid organizer email' do
          context 'passing an invalid email' do
            it 'responds 404' do
              patch :add_organizer, params: { id: event, email: 'bla' }, xhr: true
              expect(response.status).to eq 404
            end
          end
          context 'passing a valid email and the user is not organizer' do
            let(:not_organizer) { FactoryGirl.create :user }
            it 'responds 404' do
              patch :add_organizer, params: { id: event, email: not_organizer.email }, xhr: true
              expect(response.status).to eq 404
            end
          end
        end
      end
      context 'with valid parameters' do
        context 'and the user has the organizer role' do
          let(:organizer) { FactoryGirl.create :user, roles: [:organizer] }
          it 'adds the user as organizer' do
            patch :add_organizer, params: { id: event, email: organizer.email }, xhr: true
            expect(response.status).to eq 200
            expect(event.reload.organizers).to include organizer
          end
        end

        context 'and the user is already an organizer' do
          let(:organizer) { FactoryGirl.create :user, roles: [:organizer] }
          before do
            event.organizers << organizer
            event.save!
          end
          it 'adds the user as organizer' do
            patch :add_organizer, params: { id: event, email: organizer.email }, xhr: true
            expect(response.status).to eq 200
            expect(event.reload.organizers.count).to eq 1
          end
        end
        context 'and the user has the admin role' do
          let(:admin) { FactoryGirl.create :user, roles: [:admin] }
          it 'adds the user as organizer' do
            patch :add_organizer, params: { id: event, email: admin.email }, xhr: true
            expect(response.status).to eq 200
            expect(event.reload.organizers).to include admin
          end
        end
      end
    end

    describe 'DELETE #remove_organizer' do
      let(:event) { FactoryGirl.create :event }
      context 'with invalid parameters' do
        context 'and invalid event' do
          it 'responds 404' do
            delete :remove_organizer, params: { id: 'foo' }, xhr: true
            expect(response.status).to eq 404
          end
        end
        context 'and invalid organizer email' do
          context 'passing an invalid email' do
            it 'responds 404' do
              delete :remove_organizer, params: { id: event, email: 'bla' }, xhr: true
              expect(response.status).to eq 404
            end
          end
        end
      end
      context 'with valid parameters' do
        context 'and the user is already an organizer' do
          let(:organizer) { FactoryGirl.create :user, roles: [:organizer] }
          it 'removes the organizer' do
            delete :remove_organizer, params: { id: event, email: organizer.email }, xhr: true
            expect(response.status).to eq 200
            expect(event.reload.organizers).not_to include organizer
          end
        end

        context 'and the user is not an organizer of the event' do
          let(:organizer) { FactoryGirl.create :user, roles: [:organizer] }
          let(:other_organizer) { FactoryGirl.create :user, roles: [:organizer] }
          it 'adds the user as organizer' do
            event.add_organizer_by_email!(other_organizer.email)
            delete :remove_organizer, params: { id: event, email: organizer.email }, xhr: true
            expect(event.reload.organizers.count).to eq 1
          end
        end
      end
    end
  end

  describe 'GET #show' do
    let!(:event) { FactoryGirl.create :event }
    context 'with an existent user' do
      before { get :show, params: { id: event.id } }
      it { expect(assigns(:event)).to eq event }
      it { expect(assigns(:last_attendance_for_user)).to be_nil }
      it { expect(response).to render_template :show }
    end

    context 'with invalid parameters' do
      it 'responds 404' do
        get :show, params: { id: 'foo' }
        expect(response.status).to eq 404
      end
    end

    context 'signed in' do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
        disable_authorization
      end

      context 'with two valid attendances, the first cancelled and second pending' do
        it 'returns the event_persisted created' do
          now = Time.zone.local(2015, 4, 30, 0, 0, 0)
          Timecop.freeze(now)
          FactoryGirl.create(:attendance, event: event, user: user, status: 'cancelled')
          Timecop.return
          other_attendance = FactoryGirl.create(:attendance, event: event, user: user)
          get :show, params: { id: event.id }
          expect(assigns[:last_attendance_for_user]).to eq other_attendance
        end
      end

      context 'with two valid attendances, one in an event and the second in other event' do
        let(:other_event) { FactoryGirl.create(:event) }
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, user: user) }
        let!(:other_attendance) { FactoryGirl.create(:attendance, event: other_event, user: user) }
        before { get :show, params: { id: event.id } }
        it { expect(assigns[:last_attendance_for_user]).to eq attendance }
      end
    end
  end
end
