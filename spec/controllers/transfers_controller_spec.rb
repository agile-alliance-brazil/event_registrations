# frozen_string_literal: true

describe TransfersController, type: :controller do
  let(:event) { FactoryBot.create(:event) }
  let(:user) { FactoryBot.create(:user) }
  before do
    disable_authorization
    sign_in user
  end

  describe '#new' do
    let!(:origin) { FactoryBot.create(:attendance, event: event, status: :paid) }
    let!(:destination) { FactoryBot.create(:attendance, event: event, status: :pending) }

    context 'response' do
      before { get :new, params: { attendance_id: origin } }
      it { expect(response.code).to eq '200' }
    end

    context 'destinations' do
      context 'when the destinations are from the same event' do
        let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted) }
        let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
        before { get :new, params: { attendance_id: origin } }
        it { expect(assigns[:destinations]).to match_array [destination, accepted] }
      end

      context 'when the destinations are from a different event' do
        let!(:out_destination) { FactoryBot.create(:attendance, status: :accepted) }
        before { get :new, params: { attendance_id: origin } }
        it { expect(assigns[:destinations]).to match_array [destination] }
      end
    end

    context 'empty' do
      before { get :new, params: { attendance_id: origin } }
      it { expect(assigns[:event]).to be_new_record }
      it 'should set empty transfer' do
        expect(assigns[:transfer].origin_id).to be_nil
        expect(assigns[:transfer].destination_id).to be_nil
      end
    end
    context 'with origin' do
      before { get :new, params: { attendance_id: origin, transfer: { origin_id: origin.id } } }
      it { expect(assigns[:event]).to eq origin.event }
      it { expect(assigns[:transfer].origin).to eq origin }
    end
    context 'with destination' do
      before { get :new, params: { attendance_id: origin, transfer: { destination_id: destination.id } } }
      it { expect(assigns[:event]).to eq destination.event }
      it { expect(assigns[:transfer].destination).to eq destination }
    end
    context 'with origin and destination' do
      before { get :new, params: { attendance_id: origin, transfer: { origin_id: origin.id, destination_id: destination.id } } }
      it { expect(assigns[:event]).to eq origin.event }
      it 'set transfer origin and destination' do
        expect(assigns[:transfer].origin).to eq origin
        expect(assigns[:transfer].destination).to eq destination
      end
    end

    context 'as an organizer' do
      before { user.add_role :organizer }
      after { user.remove_role :organizer }
      it 'set potential transfer origins as all paid or confirmed attendances' do
        get :new, params: { attendance_id: origin }
        expect(assigns[:origins]).to match_array [origin]
      end
    end

    context 'as a guest' do
      let!(:paid) { FactoryBot.create(:attendance, status: :paid, user: user) }
      let!(:other_paid) { FactoryBot.create(:attendance, status: :paid, user: user) }
      let!(:out_paid) { FactoryBot.create(:attendance, status: :paid) }
      before { get :new, params: { attendance_id: origin } }
      it { expect(assigns[:origins]).to eq [paid, other_paid] }
    end

    context 'as a admin' do
      context 'origins' do
        before { user.add_role(:admin) }
        after { user.remove_role(:admin) }
        context 'when the origins are from the event' do
          let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
          let!(:other_paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
          let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed) }
          before { get :new, params: { attendance_id: origin } }
          it { expect(assigns[:origins]).to match_array [origin, paid, other_paid, confirmed] }
        end

        context 'when the origins are from a different event' do
          let!(:out_origin) { FactoryBot.create(:attendance, status: :paid) }
          before { get :new, params: { attendance_id: origin.id } }
          it { expect(assigns[:origins]).to match_array [origin] }
        end
      end
    end
  end

  describe '#create' do
    let!(:origin) { FactoryBot.create(:attendance, event: event, status: :paid, registration_value: 420) }
    let!(:origin_invoice) { Invoice.from_attendance(origin) }
    let!(:destination) { FactoryBot.create(:attendance, event: event, status: :pending, registration_value: 540) }
    subject(:assigned_origin) { Attendance.find(origin.id) }
    subject(:assigned_destination) { Attendance.find(destination.id) }

    context 'when origin is paid' do
      before { post :create, params: { transfer: { origin_id: origin.id, destination_id: destination.id } } }
      it 'changes the status and the registration value for an attendances and save them' do
        expect(flash[:notice]).to eq I18n.t('flash.transfer.success')
        expect(assigned_origin.status).to eq 'cancelled'
        expect(assigned_destination.status).to eq 'confirmed'
        expect(assigned_destination.registration_value).to eq 420
        expect(response).to redirect_to attendance_path(id: origin.id)
      end
    end

    context 'when origin is confirmed' do
      let!(:origin) { FactoryBot.create(:attendance, status: :confirmed, registration_value: 420) }
      before { post :create, params: { transfer: { origin_id: origin.id, destination_id: destination.id } } }
      it 'changes the status and the registration value for an attendances and save them' do
        expect(assigned_origin.status).to eq 'cancelled'
        expect(assigned_destination.status).to eq 'confirmed'
        expect(assigned_destination.registration_value).to eq 420
      end
    end

    context 'when destination is accepted' do
      let!(:destination) { FactoryBot.create(:attendance, status: :accepted) }
      before { post :create, params: { transfer: { origin_id: origin.id, destination_id: destination.id } } }
      it 'changes the status and the registration value for an attendances and save them' do
        expect(assigned_origin.status).to eq 'cancelled'
        expect(assigned_destination.status).to eq 'confirmed'
        expect(assigned_destination.registration_value).to eq 420
      end
    end

    context 'forbidden transfer' do
      let!(:paid) { FactoryBot.create(:attendance, status: :paid, user: user) }
      it 'renders transfer form again' do
        post :create, params: { transfer: { origin_id: origin.id, destination_id: paid.id } }
        is_expected.to render_template :new
        expect(flash[:error]).to eq I18n.t('flash.transfer.failure')
      end
    end
  end
end
