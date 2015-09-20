require 'spec_helper'

describe Transfer, type: :model do
  let(:origin_date) { 1.month.from_now }
  let!(:origin) { FactoryGirl.create(:attendance, id: 1, status: :paid, registration_value: 420, registration_date: origin_date) }
  let!(:destination) { FactoryGirl.create(:attendance, id: 2, status: :pending, registration_value: 540) }
  let(:transfer) { Transfer.build(origin_id: origin.id, destination_id: destination.id) }
  subject(:new_origin) { Attendance.find(origin.id) }
  subject(:new_destination) { Attendance.find(destination.id) }

  it { expect(transfer).not_to be_persisted }

  context 'validations' do
    it { expect(transfer).to be_valid }

    it 'not be valid without origin' do
      transfer = Transfer.build(destination_id: destination.id)
      expect(transfer).not_to be_valid
    end
    it 'not be valid with pending origin' do
      origin = FactoryGirl.create(:attendance, status: :pending)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).not_to be_valid
    end
    it 'not be valid with cancelled origin' do
      origin = FactoryGirl.create(:attendance, status: :cancelled)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).not_to be_valid
    end

    it 'not be valid without destination' do
      transfer = Transfer.build(origin_id: origin.id)
      expect(transfer).not_to be_valid
    end
    it 'not be valid with paid destination' do
      destination = FactoryGirl.create(:attendance, status: :paid)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).not_to be_valid
    end
    it 'not be valid with confirmed destination' do
      destination = FactoryGirl.create(:attendance, status: :confirmed)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).not_to be_valid
    end
    it 'not be valid with cancelled destination' do
      destination = FactoryGirl.create(:attendance, status: :cancelled)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).not_to be_valid
    end
    it 'be valid with confirmed origin and pending destination' do
      origin = FactoryGirl.create(:attendance, status: :confirmed)
      transfer = Transfer.build(origin_id: origin.id, destination_id: destination.id)
      expect(transfer).to be_valid
    end
  end

  context 'saving' do
    it 'not try to change origin id' do
      transfer.save
      expect(new_origin.id).to eq 1
    end
    it 'not change origin registration_date' do
      transfer.save
      expect(new_origin.registration_date).to eq origin_date
    end
    it 'cancels the origin attendance' do
      transfer.save
      expect(new_origin.status).to eq 'cancelled'
    end

    it 'change the destination status and registration value' do
      transfer.save
      expect(new_destination.status).to eq 'confirmed'
      expect(new_destination.registration_value).to eq 420
    end

    it 'also changes the related invoice' do
      Invoice.from_attendance(origin, Invoice::GATEWAY)
      Invoice.from_attendance(destination, Invoice::GATEWAY)
      transfer.save
      expect(new_origin.invoices.last.status).to eq 'cancelled'
      expect(new_destination.invoices.last.status).to eq 'paid'
      expect(new_destination.invoices.last.amount).to eq 420
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