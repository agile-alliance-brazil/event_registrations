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
  describe 'GET #show' do
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
end
