require 'spec_helper'

describe Invoice, type: :model do
  let(:event) { FactoryGirl.create :event }

  context 'associations' do
    it { should belong_to :user }
    it { should belong_to :registration_group }
    it { should have_and_belong_to_many :attendances }
  end

  describe '.from_attendance' do
    let(:individual) { event.registration_types.first }
    let!(:period) { RegistrationPeriod.create(event: event, start_at: 1.month.ago, end_at: 1.month.from_now) }
    let!(:price) { RegistrationPrice.create!(registration_type: individual, registration_period: period, value: 100.00) }
    let(:group) { RegistrationGroup.create! event: event, discount: 20 }
    let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_value: 100) }

    context 'with no pending invoice already existent' do
      subject(:invoice) { Invoice.from_attendance(attendance) }
      it { expect(invoice.user).to eq attendance.user }
      it { expect(invoice.amount).to eq attendance.event.registration_price_for(attendance) }
    end

    context 'with an already registered invoice for another user' do
      let(:user) { FactoryGirl.create :user }
      let!(:invoice) { FactoryGirl.create(:invoice, user: user, amount: 200) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_value: 100) }
      subject!(:other_invoice) { Invoice.from_attendance(attendance) }
      it { expect(other_invoice.user).to eq attendance.user }
      it { expect(other_invoice.amount).to eq 100 }
    end

    context 'with an already existent pending invoice' do
      context 'with same registration value' do
        let!(:invoice) { FactoryGirl.create(:invoice, user: attendance.user, amount: 100) }
        subject!(:other_invoice) { Invoice.from_attendance(attendance) }
        it { expect(other_invoice).to eq invoice }
        it { expect(Invoice.count).to eq 1 }
      end
      context 'with different registration_value' do
        let!(:invoice) { FactoryGirl.create(:invoice, user: attendance.user, amount: 100) }
        let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, user: attendance.user, registration_value: 200) }

        subject!(:other_invoice) { Invoice.from_attendance(other_attendance) }
        it { expect(other_invoice.amount).to eq 200 }
        it { expect(Invoice.count).to eq 1 }
      end
    end
  end

  describe '.from_registration_group' do
    let(:user) { FactoryGirl.create :user }
    let(:group) { FactoryGirl.create :registration_group, leader: user }

    context 'with no pending invoice already existent' do
      subject(:invoice) { Invoice.from_registration_group(group) }
      it { expect(invoice.registration_group).to eq group }
      it { expect(invoice.user).to eq group.leader }
    end

    context 'with an already registered invoice for another user' do
      let(:other_user) { FactoryGirl.create :user }
      let!(:invoice) { FactoryGirl.create(:invoice, user: group.leader, registration_group: group, amount: 200) }
      let!(:other_group) { FactoryGirl.create(:registration_group, leader: other_user) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, user: other_user, registration_group: other_group, registration_value: 100) }
      subject!(:other_invoice) { Invoice.from_attendance(attendance) }
      it { expect(other_invoice.user).to eq other_group.leader }
      it { expect(other_invoice.amount).to eq 100 }
    end

    context 'with an already existent invoice' do
      context 'with same total price' do
        let!(:invoice) { FactoryGirl.create(:invoice, registration_group: group, amount: group.total_price) }
        subject!(:other_invoice) { Invoice.from_registration_group(group) }
        it { expect(other_invoice).to eq invoice }
        it { expect(Invoice.count).to eq 1 }
      end

      context 'with different total price' do
        let!(:invoice) { FactoryGirl.create(:invoice, registration_group: group, amount: 100) }
        let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, user: user, registration_group: group, registration_value: 200) }

        subject!(:other_invoice) { Invoice.from_registration_group(group) }
        it { expect(other_invoice.amount).to eq 200 }
        it { expect(Invoice.count).to eq 1 }
      end
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

  describe '#cancel_it' do
    let(:invoice) { FactoryGirl.create :invoice }
    before { invoice.cancel_it }
    it { expect(invoice.status).to eq Invoice::CANCELLED }
  end
end
