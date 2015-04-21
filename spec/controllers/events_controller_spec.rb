describe EventsController, type: :controller do

  describe '#show' do
    let!(:event) { FactoryGirl.create :event }
    context 'with an existent user' do
      before { get :show, id: event.id }
      it { expect(assigns(:event)).to eq event }
      it { expect(response).to render_template :show }
    end

    context 'with an inexistent user' do
      it { expect { get :show, id: 'foo' }.to raise_error ActiveRecord::RecordNotFound }
    end
  end

  describe '#index' do
    context 'without events at the right period' do
      before { get :index }
      it { expect(assigns(:events)).to match_array [] }
    end

    context 'with events' do
      let!(:event) { Event.create name: 'Foo' }
      let!(:registration_period) { RegistrationPeriod.create!(event: event, start_at: Date.today - 1, end_at: Date.today + 1.months) }

      context 'and one event at the right period' do
        before { get :index }
        it { expect(assigns(:events)).to match_array [event] }
      end

      context 'and two at the right period' do
        let!(:other_event) { FactoryGirl.create :event }
        let!(:other_period) { RegistrationPeriod.create!(event: other_event, start_at: Date.today - 1, end_at: Date.today + 2.months) }
        before { get :index }
        it { expect(assigns(:events)).to match_array [event, other_event] }
      end

      context  'and one at the right period and other not' do
        let!(:out) { Event.create name: 'Bar' }
        let!(:other_period) { RegistrationPeriod.create!(event: out, start_at: 2.years.ago, end_at: 1.year.ago) }
        before { get :index }
        it { expect(assigns(:events)).to match_array [event] }
      end

      context 'and two at the right period and other not' do
        let!(:other_event) { FactoryGirl.create :event }
        let!(:other_period) { RegistrationPeriod.create!(event: other_event, start_at: Date.today - 1, end_at: Date.today + 2.months) }
        let!(:out) { Event.create name: 'Bar' }
        let!(:other_period) { RegistrationPeriod.create!(event: out, start_at: 2.years.ago, end_at: 1.year.ago) }

        before { get :index }
        it { expect(assigns(:events)).to match_array [event, other_event] }
      end
    end
  end
end
