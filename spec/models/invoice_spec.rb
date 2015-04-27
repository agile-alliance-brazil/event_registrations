require 'spec_helper'

describe Invoice, type: :model do
  context 'associations' do
    it { should belong_to :user }
    it { should belong_to :registration_group }
  end

  describe '.from_attendance' do
    let(:event) { FactoryGirl.create :event }
    let(:individual) { event.registration_types.first }
    let!(:period) { RegistrationPeriod.create(event: event, start_at: 1.month.ago, end_at: 1.month.from_now) }
    let!(:price) { RegistrationPrice.create!(registration_type: individual, registration_period: period, value: 100.00) }
    let(:group) { RegistrationGroup.create! event: event, discount: 20 }
    let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }

    context 'with no pending invoice already existent' do
      subject(:invoice) { Invoice.from_attendance(attendance) }
      it { expect(invoice.user).to eq attendance.user }
      it { expect(invoice.amount).to eq attendance.event.registration_price_for(attendance) }
    end

    context 'with an already existent pending invoice' do
      let!(:invoice) { FactoryGirl.create(:invoice, user: attendance.user) }
      subject!(:other_invoice) { Invoice.from_attendance(attendance) }
      it { expect(other_invoice).to eq invoice }
      it { expect(Invoice.count).to eq 1 }
    end
  end

  describe '.from_registration_group' do
    let(:user) { FactoryGirl.create :user }
    let(:group) { FactoryGirl.create :registration_group, leader: user }

    context 'with no existent invoice' do
      subject(:invoice) { Invoice.from_registration_group(group) }
      it { expect(invoice.registration_group).to eq group }
      it { expect(invoice.user).to eq group.leader }
    end

    context 'with an already existent invoice' do
      let!(:invoice) { FactoryGirl.create(:invoice, registration_group: group) }
      subject!(:other_invoice) { Invoice.from_registration_group(group) }
      it { expect(other_invoice).to eq invoice }
      it { expect(Invoice.count).to eq 1 }
    end
  end

  describe '#pay_it' do
    let(:invoice) { FactoryGirl.create :invoice }
    before { invoice.pay_it }
    it { expect(invoice.status).to eq Invoice::PAID }
  end

  describe '#send_it' do
    let(:invoice) { FactoryGirl.create :invoice }
    before { invoice.send_it }
    it { expect(invoice.status).to eq Invoice::SENT }
  end

  describe '#pending?' do
    context 'with a pending invoice' do
      let(:invoice) { FactoryGirl.create :invoice, status: Invoice::PENDING }
      it { expect(invoice.pending?).to be_truthy }
    end

    context 'with a paid invoice' do
      let(:invoice) { FactoryGirl.create :invoice, status: Invoice::PAID }
      it { expect(invoice.pending?).to be_falsey }
    end

    context 'with a sent invoice' do
      let(:invoice) { FactoryGirl.create :invoice, status: Invoice::SENT }
      it { expect(invoice.pending?).to be_falsey }
    end
  end
end
