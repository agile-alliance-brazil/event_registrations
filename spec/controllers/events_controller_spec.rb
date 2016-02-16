# == Schema Information
#
# Table name: events
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  location_and_date :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  price_table_link  :string(255)
#  allow_voting      :boolean
#  attendance_limit  :integer
#  full_price        :decimal(10, )
#  start_date        :datetime
#  end_date          :datetime
#

describe EventsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #list_archived' do
      it 'redirects to login' do
        get :list_archived
        expect(response).to redirect_to login_path
      end
    end

    describe 'GET #new' do
      it 'redirects to login' do
        get :new
        expect(response).to redirect_to login_path
      end
    end

    describe 'POST #create' do
      it 'redirects to login' do
        post :create
        expect(response).to redirect_to login_path
      end
    end

    describe 'DELETE destroy' do
      it 'redirects to login' do
        delete :destroy, id: 'foo'
        expect(response).to redirect_to login_path
      end
    end

    describe 'PATCH #add_organizer' do
      it 'redirects to login' do
        xhr :patch, :add_organizer, id: 'foo'
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
        delete :destroy, id: 'foo'
        expect(response).to redirect_to root_path
      end
    end

    describe 'PATCH #add_organizer' do
      it 'redirects to root' do
        xhr :patch, :add_organizer, id: 'foo'
        expect(response).to redirect_to root_path
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

      context 'with events' do
        let!(:event) { FactoryGirl.create(:event, name: 'Foo', start_date: 2.months.ago, end_date: 1.month.ago) }

        context 'and one event at the right period' do
          before { get :list_archived }
          it { expect(assigns(:events)).to match_array [event] }
        end

        context 'and two at the right period' do
          let!(:other_event) { FactoryGirl.create(:event, start_date: 3.months.ago, end_date: 2.months.ago) }
          before { get :list_archived }
          it { expect(assigns(:events)).to match_array [event, other_event] }
        end

        context 'and one at the right period and other not' do
          let!(:out) { FactoryGirl.create(:event, start_date: 1.day.ago, end_date: 1.year.from_now) }
          before { get :list_archived }
          it { expect(assigns(:events)).to match_array [event] }
        end

        context 'and two at the right period and other not' do
          let!(:other_event) { FactoryGirl.create(:event, start_date: 3.months.ago, end_date: 2.months.ago) }
          let!(:out) { FactoryGirl.create(:event, start_date: 1.day.ago, end_date: 1.year.from_now) }

          before { get :list_archived }
          it { expect(assigns(:events)).to match_array [event, other_event] }
        end
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
          post :create, event: { name: 'foo', attendance_limit: 10, start_date: start_date, end_date: end_date, full_price: 100, price_table_link: 'http://bla' }
          expect(Event.count).to eq 1
          event_persisted = Event.last
          expect(event_persisted.name).to eq 'foo'
          expect(event_persisted.attendance_limit).to eq 10
          expect(event_persisted.start_date.utc.to_i).to eq start_date.to_i
          expect(event_persisted.end_date.utc.to_i).to eq end_date.to_i
          expect(event_persisted.full_price).to eq 100
          expect(event_persisted.price_table_link).to eq 'http://bla'

          expect(response).to redirect_to event_path(event_persisted)
        end
      end

      context 'with invalid parameters' do
        subject(:event) { assigns(:event) }
        it 'renders form with the errors' do
          post :create, event: { name: '' }
          expect(event).to be_a Event
          expect(event.errors.full_messages).to eq ['Start date não pode ficar em branco', 'End date não pode ficar em branco', 'Full price não pode ficar em branco', 'Name não pode ficar em branco']
          expect(response).to render_template :new
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'with valid parameters' do
        context 'and responding to HTML' do
          let!(:event) { FactoryGirl.create :event }
          it 'deletes the event and redirects to events index' do
            delete :destroy, id: event.id
            expect(response).to redirect_to events_path
            expect(Event.count).to eq 0
          end
        end
      end

      context 'with invalid parameters' do
        it 'responds 404' do
          delete :destroy, id: 'foo'
          expect(response.status).to eq 404
        end
      end
    end

    describe 'PATCH #add_organizer' do
      let(:event) { FactoryGirl.create :event }
      context 'with invalid parameters' do
        context 'and invalid event' do
          it 'responds 404' do
            xhr :patch, :add_organizer, id: 'foo'
            expect(response.status).to eq 404
          end
        end
        context 'and invalid organizer email' do
          context 'passing an invalid email' do
            it 'responds 404' do
              xhr :patch, :add_organizer, id: event, email: 'bla'
              expect(response.status).to eq 404
            end
          end
          context 'passing a valid email and the user is not organizer' do
            let(:not_organizer) { FactoryGirl.create :user }
            it 'responds 404' do
              xhr :patch, :add_organizer, id: event, email: not_organizer.email
              expect(response.status).to eq 404
            end
          end
        end
      end
      context 'with valid parameters' do
        context 'and the user has the organizer role' do
          let(:organizer) { FactoryGirl.create :user, roles: [:organizer] }
          it 'adds the user as organizer' do
            xhr :patch, :add_organizer, id: event, email: organizer.email
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
            xhr :patch, :add_organizer, id: event, email: organizer.email
            expect(response.status).to eq 200
            expect(event.reload.organizers.count).to eq 1
          end
        end
        context 'and the user has the admin role' do
          let(:admin) { FactoryGirl.create :user, roles: [:admin] }
          it 'adds the user as organizer' do
            xhr :patch, :add_organizer, id: event, email: admin.email
            expect(response.status).to eq 200
            expect(event.reload.organizers).to include admin
          end
        end
      end
    end
  end

  describe 'GET #show' do
    let!(:event) { FactoryGirl.create :event }
    context 'with an existent user' do
      before { get :show, id: event.id }
      it { expect(assigns(:event)).to eq event }
      it { expect(assigns(:last_attendance_for_user)).to be_nil }
      it { expect(response).to render_template :show }
    end

    context 'with invalid parameters' do
      it 'responds 404' do
        get :show, id: 'foo'
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
          get :show, id: event.id
          expect(assigns[:last_attendance_for_user]).to eq other_attendance
        end
      end

      context 'with two valid attendances, one in an event and the second in other event' do
        let(:other_event) { FactoryGirl.create(:event) }
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, user: user) }
        let!(:other_attendance) { FactoryGirl.create(:attendance, event: other_event, user: user) }
        before { get :show, id: event.id }
        it { expect(assigns[:last_attendance_for_user]).to eq attendance }
      end
    end
  end

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
end
