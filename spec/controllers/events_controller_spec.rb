describe EventsController, type: :controller do
  describe '#show' do
    let!(:event) { FactoryGirl.create :event }
    context 'with an existent user' do
      before { get :show, id: event.id }
      it { expect(assigns(:event)).to eq event }
      it { expect(assigns(:last_attendance_for_user)).to be_nil }
      it { expect(response).to render_template :show }
    end

    context 'with an inexistent user' do
      it { expect { get :show, id: 'foo' }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'signed in' do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
        disable_authorization
      end

      context 'with two valid attendances, the first cancelled and second pending' do
        it 'returns the last created' do
          now = Time.zone.local(2015, 4, 30, 0, 0, 0)
          Timecop.freeze(now)
          attendance = FactoryGirl.create(:attendance, event: event, user: user, status: 'cancelled')
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

  describe '#index' do
    context 'without events at the right period' do
      before { get :index }
      it { expect(assigns(:events)).to match_array [] }
    end

    context 'with events' do
      let!(:event) { Event.create name: 'Foo', start_date: Time.zone.today - 1, end_date: Time.zone.today + 1.month }

      context 'and one event at the right period' do
        before { get :index }
        it { expect(assigns(:events)).to match_array [event] }
      end

      context 'and two at the right period' do
        let!(:other_event) { Event.create start_date: Time.zone.today - 1, end_date: Time.zone.today + 2.months }
        before { get :index }
        it { expect(assigns(:events)).to match_array [event, other_event] }
      end

      context 'and one at the right period and other not' do
        let!(:out) { Event.create start_date: 2.years.ago, end_date: 1.year.ago }
        before { get :index }
        it { expect(assigns(:events)).to match_array [event] }
      end

      context 'and two at the right period and other not' do
        let!(:other_event) { Event.create start_date: Time.zone.today - 1, end_date: Time.zone.today + 2.months }
        let!(:out) { Event.create start_date: 2.years.ago, end_date: 1.year.ago }

        before { get :index }
        it { expect(assigns(:events)).to match_array [event, other_event] }
      end
    end
  end
end
