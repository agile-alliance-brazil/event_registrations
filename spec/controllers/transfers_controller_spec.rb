# frozen_string_literal: true

RSpec.describe TransfersController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'POST #create' do
      before { post :create, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
  end

  context 'as a normal user' do
    let(:event) { FactoryBot.create :event }
    let(:user) { FactoryBot.create :user }
    before { sign_in user }

    describe 'GET #new' do
      before { get :new, params: { event_id: event } }
      it 'redirects to root_path with a message' do
        expect(response).to redirect_to root_path
        expect(flash[:error]).to eq I18n.t('flash.unauthorised')
      end
    end
  end

  context 'as an organizer' do
    let(:user) { FactoryBot.create(:organizer) }
    let(:event) { FactoryBot.create(:event, organizers: [user]) }

    before { sign_in user }

    describe 'GET #new' do
      let!(:origin) { FactoryBot.create(:attendance, event: event, status: :paid) }
      let!(:destination) { FactoryBot.create(:attendance, event: event, status: :pending) }

      context 'having data' do
        let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted) }
        let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
        let!(:out_destination) { FactoryBot.create(:attendance, status: :accepted) }

        before { get :new, params: { event_id: event } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :new
          expect(assigns[:destinations]).to match_array [destination, accepted]
        end
      end

      context 'empty' do
        it 'sets empty transfer' do
          get :new, params: { event_id: event }
          expect(assigns[:transfer].origin_id).to be_nil
          expect(assigns[:transfer].destination_id).to be_nil
        end
      end
      context 'with origin' do
        before { get :new, params: { event_id: event, transfer: { origin_id: origin } } }
        it { expect(assigns[:event]).to eq origin.event }
        it { expect(assigns[:transfer].origin).to eq origin }
      end
      context 'with destination' do
        before { get :new, params: { event_id: event, transfer: { destination_id: destination } } }
        it { expect(assigns[:event]).to eq destination.event }
        it { expect(assigns[:transfer].destination).to eq destination }
      end
      context 'with origin and destination' do
        before { get :new, params: { event_id: event, transfer: { origin_id: origin.id, destination_id: destination } } }
        it { expect(assigns[:event]).to eq origin.event }
        it 'set transfer origin and destination' do
          expect(assigns[:transfer].origin).to eq origin
          expect(assigns[:transfer].destination).to eq destination
        end
      end
    end

    describe 'POST #create' do
      let!(:origin) { FactoryBot.create(:attendance, event: event, status: :paid, registration_value: 420) }
      let!(:origin_invoice) { Invoice.from_attendance(origin) }
      let!(:destination) { FactoryBot.create(:attendance, event: event, status: :pending, registration_value: 540) }
      subject(:assigned_origin) { Attendance.find(origin.id) }
      subject(:assigned_destination) { Attendance.find(destination.id) }

      context 'when origin is paid' do
        before { post :create, params: { event_id: event, transfer: { origin_id: origin, destination_id: destination } } }
        it 'changes the status and the registration value for an attendances and save them' do
          expect(flash[:notice]).to eq I18n.t('flash.transfer.success')
          expect(assigned_origin.status).to eq 'cancelled'
          expect(assigned_destination.status).to eq 'confirmed'
          expect(assigned_destination.registration_value).to eq 420
          expect(response).to redirect_to event_attendance_path(event, origin)
        end
      end

      context 'when origin is confirmed' do
        let!(:origin) { FactoryBot.create(:attendance, event: event, status: :confirmed, registration_value: 420) }
        before { post :create, params: { event_id: event, transfer: { origin_id: origin, destination_id: destination } } }
        it 'changes the status and the registration value for an attendances and save them' do
          expect(assigned_origin.status).to eq 'cancelled'
          expect(assigned_destination.status).to eq 'confirmed'
          expect(assigned_destination.registration_value).to eq 420
        end
      end

      context 'when destination is accepted' do
        let!(:destination) { FactoryBot.create(:attendance, event: event, status: :accepted) }
        before { post :create, params: { event_id: event, transfer: { origin_id: origin, destination_id: destination } } }
        it 'changes the status and the registration value for an attendances and save them' do
          expect(assigned_origin.status).to eq 'cancelled'
          expect(assigned_destination.status).to eq 'confirmed'
          expect(assigned_destination.registration_value).to eq 420
        end
      end

      context 'forbidden transfer' do
        let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid, user: user) }
        it 'renders transfer form again' do
          post :create, params: { event_id: event, transfer: { origin_id: origin, destination_id: paid } }
          expect(response).to render_template :new
          expect(flash[:error]).to eq I18n.t('flash.transfer.failure')
        end
      end
    end
  end

  context 'as an admin' do
    let(:admin) { FactoryBot.create(:admin) }
    let(:event) { FactoryBot.create(:event) }

    before { sign_in admin }

    context 'origins' do
      context 'when the origins are from the event' do
        let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
        let!(:other_paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
        let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed) }
        let!(:out_origin) { FactoryBot.create(:attendance, status: :paid) }

        before { get :new, params: { event_id: event } }
        it { expect(assigns[:origins]).to match_array [paid, other_paid, confirmed] }
      end
    end
  end
end
