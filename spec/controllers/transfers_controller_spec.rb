# encoding: UTF-8
require 'spec_helper'

describe TransfersController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  before do
    disable_authorization
    sign_in user
  end

  describe '#new' do
    let!(:origin) { FactoryGirl.create(:attendance, status: :paid) }
    let!(:destination) { FactoryGirl.create(:attendance, status: :pending) }

    context 'response' do
      before { get :new }
      it { expect(response.code).to eq '200' }
    end

    context 'destination' do
      let!(:pending) { FactoryGirl.create(:attendance, status: :pending) }
      let!(:paid) { FactoryGirl.create(:attendance, status: :paid) }
      before { get :new }
      it { expect(assigns[:destinations]).to match_array [destination, pending] }
    end

    context 'empty' do
      before { get :new }
      it { expect(assigns[:event]).to be_new_record }
      it 'should set empty transfer' do
        expect(assigns[:transfer]).to be_new_record
        expect(assigns[:transfer].origin_id).to be_nil
        expect(assigns[:transfer].destination_id).to be_nil
      end
    end
    context 'with origin' do
      before { get :new, transfer: { origin_id: origin.id } }
      it { expect(assigns[:event]).to eq origin.event }
      it { expect(assigns[:transfer].origin).to eq origin }
    end
    context 'with destination' do
      before { get :new, transfer: { destination_id: destination.id } }
      it { expect(assigns[:event]).to eq destination.event }
      it { expect(assigns[:transfer].destination).to eq destination }
    end
    context 'with origin and destination' do
      before { get :new, transfer: { origin_id: origin.id, destination_id: destination.id } }
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
        get :new
        expect(assigns[:origins]).to match_array [origin]
      end
    end

    context 'as a guest' do
      let!(:paid) { FactoryGirl.create(:attendance, status: :paid, user: user) }
      let!(:other_paid) { FactoryGirl.create(:attendance, status: :paid, user: user) }
      let!(:out_paid) { FactoryGirl.create(:attendance, status: :paid) }
      before { get :new }
      it { expect(assigns[:origins]).to eq [paid, other_paid] }
    end

    context 'as a admin' do
      let!(:paid) { FactoryGirl.create(:attendance, status: :paid) }
      let!(:other_paid) { FactoryGirl.create(:attendance, status: :paid) }
      before { user.add_role(:admin) }
      after { user.remove_role(:admin) }
      it 'shows all paid as origin' do
        get :new
        expect(assigns[:origins]).to match_array [origin, paid, other_paid]
      end
    end
  end

  describe '#create' do
    let!(:origin) { FactoryGirl.create(:attendance, status: :paid, registration_value: 420) }
    let!(:destination) { FactoryGirl.create(:attendance, status: :pending, registration_value: 540) }
    subject(:new_origin) { Attendance.find(origin.id) }
    subject(:new_destination) { Attendance.find(destination.id) }

    context 'when origin is paid' do
      before { post :create, transfer: { origin_id: origin.id, destination_id: destination.id } }
      it 'changes the status and the registration value for an attendances and save them' do
        expect(flash[:notice]).to eq I18n.t('flash.transfer.success')
        expect(new_origin.status).to eq 'cancelled'
        expect(new_destination.status).to eq 'paid'
        expect(new_destination.registration_value).to eq 420
        expect(response).to redirect_to attendance_path(id: origin.id)
      end
    end

    context 'when origin is confirmed' do
      let!(:origin) { FactoryGirl.create(:attendance, status: :confirmed, registration_value: 420) }
      before { post :create, transfer: { origin_id: origin.id, destination_id: destination.id } }
      it 'changes the status and the registration value for an attendances and save them' do
        expect(Attendance.find(origin.id).status).to eq 'cancelled'
        expect(new_destination.status).to eq 'confirmed'
        expect(new_destination.registration_value).to eq 420
      end
    end

    context 'forbidden transfer' do
      let!(:paid) { FactoryGirl.create(:attendance, status: :paid, user: user) }
      it 'renders transfer form again' do
        post :create, transfer: { origin_id: origin.id, destination_id: paid.id }
        expect(response).to render_template :new
        expect(flash[:error]).to eq I18n.t('flash.transfer.failure')
      end
    end
  end
end
