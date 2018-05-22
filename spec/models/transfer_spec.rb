# frozen_string_literal: true

RSpec.describe Transfer, type: :model do
  let(:origin_date) { 1.month.from_now }
  let!(:origin) { FactoryBot.create(:attendance, id: 1, status: :paid, registration_value: 420, registration_date: origin_date) }
  let!(:destination) { FactoryBot.create(:attendance, id: 2, status: :pending, registration_value: 540) }
  let(:transfer) { Transfer.build(origin_id: origin.id, destination_id: destination.id) }

  it { expect(transfer).not_to be_persisted }

  context 'validations' do
    it { expect(transfer).to be_valid }

    it 'not be valid without origin' do
      transfer = Transfer.build(destination_id: destination.id)
      expect(transfer).not_to be_valid
    end
    it 'not be valid with pending origin' do
      origin = FactoryBot.create(:attendance, status: :pending)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).not_to be_valid
    end
    it 'not be valid with cancelled origin' do
      origin = FactoryBot.create(:attendance, status: :cancelled)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).not_to be_valid
    end

    it 'not be valid without destination' do
      transfer = Transfer.build(origin_id: origin.id)
      expect(transfer).not_to be_valid
    end
    it 'not be valid with paid destination' do
      destination = FactoryBot.create(:attendance, status: :paid)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).not_to be_valid
    end
    it 'not be valid with confirmed destination' do
      destination = FactoryBot.create(:attendance, status: :confirmed)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).not_to be_valid
    end
    it 'not be valid with cancelled destination' do
      destination = FactoryBot.create(:attendance, status: :cancelled)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).not_to be_valid
    end
    it 'be valid with confirmed origin and pending destination' do
      origin = FactoryBot.create(:attendance, status: :confirmed)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).to be_valid
    end
  end

  describe '#save' do
    subject(:assigned_origin) { Attendance.find(origin.id) }
    subject(:assigned_destination) { Attendance.find(destination.id) }

    it 'not try to change origin id' do
      transfer.save
      expect(assigned_origin.id).to eq 1
    end
    it 'do the transfer and keep the dates' do
      origin.paid!

      destination_date = destination.registration_date
      origin_date = origin.registration_date
      transfer.save
      expect(assigned_origin.status).to eq 'cancelled'
      expect(assigned_origin.registration_date.to_i).to eq origin_date.to_i
      expect(assigned_destination.registration_date.to_i).to eq destination_date.to_i
      expect(assigned_destination.status).to eq 'paid'
      expect(assigned_destination.registration_value).to eq 420
    end
  end

  context 'build' do
    it 'should create empty transfer from empty hash' do
      transfer = Transfer.build({})

      expect(transfer.origin).to be_new_record
      expect(transfer.origin.id).to be_nil
      expect(transfer.destination).to be_new_record
      expect(transfer.destination.id).to be_nil
    end
    it 'should create transfer with origin if hash has origin_id' do
      transfer = Transfer.build(origin_id: origin.id)

      expect(transfer.origin).to eq(origin)
    end
    it 'should create transfer with destination if hash has destination_id' do
      transfer = Transfer.build(destination_id: destination.id)

      expect(transfer.destination).to eq destination
    end
  end
end
