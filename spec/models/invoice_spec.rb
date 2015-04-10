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

    subject(:invoice) { Invoice.from_attendance(attendance) }

    it { expect(invoice.user).to eq attendance.user }
    it { expect(invoice.amount).to eq attendance.registration_fee }
  end

  describe '.from_registration_group' do
    let(:user) { FactoryGirl.create :user }
    let(:group) { FactoryGirl.create :registration_group, leader: user }
    subject(:invoice) { Invoice.from_registration_group(group) }

    it { expect(invoice.registration_group).to eq group }
    it { expect(invoice.user).to eq group.leader }
  end
end